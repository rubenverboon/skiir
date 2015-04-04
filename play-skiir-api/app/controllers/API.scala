package controllers

import java.util.Date

import anorm.SqlParser._
import anorm._
import models.{Annotation, Article, Request}
import play.api.Play.current
import play.api.UsefulException
import play.api.db.DB
import play.api.libs.json.Json._
import play.api.libs.json.{JsValue, JsArray, Json}
import play.api.mvc._
import semanticate.Highlighter

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

object API extends Controller {

  val articleUrlLength = 200
  val articleTitleLength = 100

  def articles = Action { request =>
    val params = request.queryString.mapValues(_.headOption)
    Ok(JsArray(getArticles(params)))
  }

  def requests = Action {
    Ok(getRequests())
  }

  def getArticles(filter: Map[String,Option[String]]) = {
    val allowed_filter = filter.filterKeys(Seq("id", "url").contains)
    DB.withConnection { implicit c =>
      val sql = "SELECT * FROM article" + (if(allowed_filter.nonEmpty) allowed_filter.map(t => s"article_${t._1} = {${t._1}}").mkString(" WHERE ", " AND ", "") else "")
      val query = SQL(sql).on(allowed_filter.map(t => NamedParameter(t._1, t._2)).toSeq :_*)
      query().map(row => Article.fromRow(row).toJson - "text").toList
    }
  }

  def singleArticle() = Action { request =>
    val params = request.queryString.mapValues(_.headOption).map {
      case ("url", Some(u)) => "url" -> Some(u.take(articleUrlLength))
      case t => t
    }
    val resultList = getArticles(params)
    try
      resultList.singleOption.map(_ \ "id").flatMap(_.asOpt[Long]).map(id =>
        Ok(resultList(0) - "text" ++ Json.obj(
          "requests" -> getRequests(Some(id)),
          "annotations" -> getAnnotations(Some(id)),
          "links" -> Json.arr(Json.obj(
            "rel" -> "request",
            "href" -> (controllers.routes.API.addRequestToArticle(id).toString),
            "method" -> controllers.routes.API.addRequestToArticle(id).method,
            "note" -> "Add a Request. You MAY provide the article_url, but it will not be used."
          ))
        ))
      ).getOrElse(NotFound(Json.obj(
        "links" -> Json.arr(Json.obj(
          "rel" -> "request",
          "href" -> (controllers.routes.API.addRequestForArticleUrl().toString),
          "method" -> controllers.routes.API.addRequestForArticleUrl().method,
          "note" -> "Add a Request. You MUST provide the article_url"
        ), Json.obj(
          "rel" -> "crawl",
          "href" -> (controllers.routes.Crawler.crawl("url").toString),
          "method" -> controllers.routes.Crawler.crawl("url").method,
          "note" -> "Crawl without adding Request. You MUST replace 'url' with a url-encoded URL."
        ))
      )))
    catch {
      case e: NonSingletonListException => BadRequest(s"Provide GET parameters that discriminate the articles to a unique article.")
    }
  }

  def articleById(id: Long) = Action { DB.withConnection { implicit c =>
    SQL"""SELECT * FROM article WHERE article_id = ${id}"""()
      .map(Article.fromRow).map(a => a.toJson - "text" ++ Json.obj(
        "requests" -> getRequests(Some(a.id)),
        "annotations" -> getAnnotations(Some(a.id)),
        "actions" -> Json.obj(
          "addRequest" -> controllers.routes.API.addRequestToArticle(a.id).toString
        )
      )).map(Ok(_))
      .toList.singleOption
      .getOrElse(NotFound)
  }}

  def getRequests(article_id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = article_id match {
        case Some(aid) => SQL("SELECT * FROM request WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM request")
      }
      val rows = query().map(models.Request.fromRow).map(req => req.toJson ++ Json.obj(
        "actions" -> Json.obj(
          "annotate" -> controllers.routes.API.addAnnotation(req.id).toString,
          "relatedArticles" -> controllers.routes.API.getRelatedArticlesOnRequest(req.id).toString,
          "annotations" -> controllers.routes.API.getAnnotationsRequest(req.id).toString
        )
      )).toList
      JsArray(rows)
    }
  }

  def getAnnotationsRequest(request_id: Long) = Action {
    DB.withConnection { implicit c =>
      val query = SQL"""SELECT * FROM annotation WHERE request_id =${request_id}"""
      Ok(JsArray(query().map(Annotation.fromRow).map(a=>a.toJson).toList))
    }
  }

  def getAnnotations(article_id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = article_id match {
        case Some(aid) => SQL("SELECT * FROM annotation WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM article")
      }
      query().map(Annotation.fromRow).map(ann => ann.toJson ++ Json.obj(
        "actions" -> Json.obj(
          "vote" -> controllers.routes.API.voteAnnotation(ann.request_id, ann.article_id).toString
        )
      )).toList
    }
  }

  def getRelatedArticlesOnRequest(reqid: Long) = Action {
    DB.withConnection {implicit c =>
      val req = SQL("SELECT * FROM request WHERE request_id= {id}").on('id -> reqid)().map(Request.fromRow).toList.head

      // Entities that can be found in the text_surroundings
      val selectedEntities = SQL"""SELECT entity_id FROM entity_article WHERE article_id = ${req.article_id} AND ${req.text_surroundings} ILIKE '%'||text||'%'""" as { scalar[Long].* }

      val query = SQL("SELECT article.*\n" +
          "FROM \n" +
            "(SELECT SUM(relevance) AS rel, article_id\n" +
             "FROM (entity JOIN entity_article ON entity.entity_id = entity_article.entity_id)\n" +
             "WHERE {text} ILIKE '%'||entity_name||'%'\n" +
                "AND article_id != {aid}\nGROUP BY article_id\n" +
             "ORDER BY rel DESC\nLIMIT 4) AS c JOIN article ON c.article_id = article.article_id")
      .on('text -> req.text_surroundings)
      .on('aid -> req.article_id)
      Ok(JsArray(query().map(Article.fromRow).map(a => {
        val words = SQL(s"SELECT text FROM entity_article WHERE article_id = ${a.id} AND entity_id IN (${selectedEntities.mkString(",")})") as { scalar[String].* }
        a.toJson ++ Json.obj(
          "snippets" -> Highlighter.highlight(a.text, words).map(_.toJson(a.text)).toList
        )
      }).toList))
    }
  }

  def getRelatedArticles(aid: Long) = Action {
    DB.withConnection{ implicit c=>
      val a = SQL"""SELECT article.*
FROM article JOIN (
SELECT b.article_id AS id , SUM(b.relevance) AS rel
FROM (entity_article AS a JOIN entity_article AS b ON a.entity_id=b.entity_id)
WHERE a.article_id=${aid} AND a.article_id != b.article_id
GROUP BY b.article_id
ORDER BY rel DESC
LIMIT 4) AS c ON article.article_id = c.id"""()
        .map(row=>Article.fromRow(row).toJson).toList
      Ok(JsArray(a))
    }
  }

  /**
   * Handles new requests
   * @return A Redirect to the article to which the request was added or a BadRequest
   */
  def addRequestForArticleUrl() = Action.async { request =>
    request.body.asJson.map { json =>
      // Make sure we have the article
      Crawler.scrapeArticle((json \ "article_url").as[String])
        .map(article_id => addRequest(article_id, json))
    }.getOrElse(Future.successful(
      noJsonBody
    ))
  }

  def addRequestToArticle(aid: Long) = Action { request =>
    request.body.asJson.map(addRequest(aid, _)).getOrElse(
      noJsonBody
    )
  }
  val noJsonBody = BadRequest("Expecting Json data in request body")

  private def addRequest(aid: Long, body: JsValue) = DB.withConnection { implicit c =>
    // Store request
    (aid, (body \ "request_text").asOpt[String], (body \ "request_text_surroundings").asOpt[String]) match {
      case (aid, Some(text), Some(surround)) =>
        // If we have all parameters then insert
        val id = SQL"""INSERT INTO request
            (article_id, request_text, request_text_surroundings, date_asked)
            VALUES ($aid,$text,$surround,${new Date})""".executeInsert[Option[Long]]()
        id match {
          case Some(req) => Created(Json.obj(
            "actions" -> Json.obj(
              "annotate" -> routes.API.addAnnotation(req).toString,
              "article" -> routes.API.getRelatedArticlesOnRequest(aid).toString
            )
          )).withHeaders("Location" -> (routes.API.singleArticle() + s"?id=$aid&req_id=$req"))
          case _ => BadRequest("Something went wrong while inserting request")
        }
      case _ => BadRequest("Provide the fields article_id, request_text, request_text_surroundings. Instead of giving an article_id an article can be directly looked up/created by providing article_url, article_text and article_date.")
    }
  }

  def addAnnotation(rid: Long) = Action { request => DB.withConnection { implicit c =>
    request.body.asJson map { json =>
      val id = SQL("INSERT INTO annotation " +
        "(request_id, article_id, annotation_answer, date_answered, refs) VALUES " +
        "({rid}, (SELECT article_id FROM request WHERE request_id = {rid}), {expl}, {date}, {refs})").on(
          'rid -> rid,
          'expl -> (json \ "explanation").as[String],
          'date -> new Date(),
          'refs -> (json \ "references").toString
        ).executeInsert[Option[Long]]()
      Created("").withHeaders("Location" -> s"requests/$rid/annotations/$id")
    } getOrElse noJsonBody
  }}

  def voteAnnotation(rid: Long, eid: Long) = Action { request => DB.withConnection { implicit c =>
    val rows = SQL"""UPDATE annotation SET votes = votes + 1 WHERE annotation_id = $eid""".executeUpdate()
    if(rows == 1)
      Ok("")
    else
      InternalServerError("Zero, or strictly more than one row, where voted on.")
  }}

  implicit class SingleOptionList[T](val list: List[T]) {
    def singleOption: Option[T] = {
      val i = list.iterator
      val res =
        if(i.hasNext)
          Some(i.next)
        else
          None

      if(i.hasNext)
        throw new NonSingletonListException("The result set contains multiple elements where only one element was expected.")
      res
    }
  }

  class NonSingletonListException(val message: String) extends UsefulException(message) {}
}
