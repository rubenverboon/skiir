package controllers.api

import anorm.SqlParser._
import anorm._
import controllers.api
import models.{Article, Request}
import play.api.Play.current
import play.api.UsefulException
import play.api.db.DB
import play.api.libs.json.{JsArray, Json}
import play.api.mvc.{Action, Controller}
import semanticate.Highlighter

object Articles extends Controller {

  val articleUrlLength = 200
  val articleTitleLength = 100
  val noJsonBody = BadRequest("Expecting Json data in request body")

  def articles = Action { request =>
    val params = request.queryString.mapValues(_.headOption)
    Ok(JsArray(getArticles(params)))
  }

  private def getArticles(filter: Map[String,Option[String]]) = {
    val allowed_filter = filter.filterKeys(Seq("id", "url").contains)
    DB.withConnection { implicit c =>
      val sql = "SELECT * FROM article" + (if(allowed_filter.nonEmpty) allowed_filter.map(t => s"article_${t._1} = {${t._1}}").mkString(" WHERE ", " AND ", "") else "")
      val query = SQL(sql).on(allowed_filter.map(t => NamedParameter(t._1, t._2)).toSeq :_*)
      query().map(row => Article.fromRow(row).toJson - "text").toList
    }
  }

  def articleByUrl(url: String) = Action { request =>
    val resultList = getArticles(Map("url" -> Some(url.take(articleUrlLength))))
    try
      resultList.singleOption.map(_ \ "id").flatMap(_.asOpt[Long]).map(id =>
        Ok(resultList(0) - "text" ++ Json.obj(
          "requests" -> api.Requests.getRequests(Some(id)),
          "annotations" -> api.Annotations.getAnnotations(Some(id)),
          "links" -> Json.arr(Json.obj(
            "rel" -> "request",
            "href" -> controllers.api.routes.Requests.addRequestToArticle(id).toString,
            "method" -> controllers.api.routes.Requests.addRequestToArticle(id).method,
            "note" -> "Add a Request. You MAY provide the article_url, but it will not be used."
          ))
        ))
      ).getOrElse(NotFound(Json.obj(
        "links" -> Json.arr(Json.obj(
          "rel" -> "request",
          "href" -> controllers.api.routes.Requests.addRequestForArticleUrl().toString,
          "method" -> controllers.api.routes.Requests.addRequestForArticleUrl().method,
          "note" -> "Add a Request. You MUST provide the article_url"
        ), Json.obj(
          "rel" -> "crawl",
          "href" -> controllers.routes.Crawler.crawl("url").toString,
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
        "requests" -> api.Requests.getRequests(Some(a.id)),
        "annotations" -> api.Annotations.getAnnotations(Some(a.id)),
        "actions" -> Json.obj(
          "addRequest" -> controllers.api.routes.Requests.addRequestToArticle(a.id).toString
        )
      )).map(Ok(_))
      .toList.singleOption
      .getOrElse(NotFound)
  }}


  def getRelatedArticlesOfRequest(reqid: Long) = Action {
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
