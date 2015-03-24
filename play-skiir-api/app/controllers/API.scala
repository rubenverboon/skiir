package controllers

import java.util.Date

import anorm.SqlParser._
import anorm._
import play.api.Play.current
import play.api.UsefulException
import play.api.db.DB
import play.api.libs.json.Json._
import play.api.libs.json.{JsArray, Json}
import play.api.mvc._

object API extends Controller {

  val articleUrlLength = 100
  val articleTitleLength = 40

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
      query().map(row => Json.obj(
        "id" -> row[Long]("article_id"),
        "url" -> row[String]("article_url"),
        "title" -> row[String]("article_title"),
        "text" -> row[String]("article_text"),
        "date" -> row[Option[Date]]("article_date"),
        "date_added" -> row[Option[Date]]("date_added")
      )).toList
    }
  }

  def singleArticle() = Action { request =>
    val params = request.queryString.mapValues(_.headOption)
    val resultList = getArticles(params)
    try
      resultList.singleOption.map(_ \ "id").flatMap(_.asOpt[Long]).map(id =>
        Ok(resultList(0) ++ Json.obj(
          "requests" -> getRequests(Some(id)),
          "annotations" -> getAnnotations(Some(id))
        ))
      ).getOrElse(NotFound)
    catch {
      case e: NonSingletonListException => BadRequest(s"Provide GET parameters that discriminate the articles to a unique article.")
    }
  }

  def getRequests(article_id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = article_id match {
        case Some(aid) => SQL("SELECT * FROM request WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM request")
      }
      val rows = query().map(row => Json.obj(
        "id" -> row[Long]("request_id"),
        "article_id" -> row[Long]("article_id"),
        "text" -> row[String]("request_text"),
        "text_surroundings" -> row[String]("request_text_surroundings"),
        "date_asked" -> row[Option[Date]]("date_asked")
      )).toList
      JsArray(rows)
    }
  }

  def getAnnotations(article_id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = article_id match {
        case Some(aid) => SQL("SELECT * FROM annotation WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM article")
      }
      query().map(row => Json.obj(
        "id" -> row[Long]("annoation_id"),
        "request_id" -> row[Long]("request_id"),
        "article_id" -> row[Long]("article_id"),
        "annotation_answer" -> row[Option[String]]("annotation_answer"),
        "date_answered" -> row[Option[Date]]("date_answered"),
        "votes" -> row[Long]("votes")
      )).toList
    }
  }

  /**
   * Handles new requests
   * @return A Redirect to the article to which the request was added or a BadRequest
   */
  def addRequest() = Action { request => DB.withConnection { implicit c =>
    request.body.asJson.map { json =>
      val urlOpt = (json \ "article_url").asOpt[String].map(_.take(articleUrlLength))
      val title = (json \ "article_title").asOpt[String].map(_.take(articleTitleLength))
      // Get article id, either given or by looking up the url, or inserting the article
      val article_id = (json \ "article_id").asOpt[Long].orElse(urlOpt.flatMap(url => {
        // Look up if we have the article already
        SQL("SELECT article_id FROM article WHERE article_url LIKE {url}").on('url -> url).as(scalar[Long].singleOpt).orElse {
          // Insert the article
          SQL("INSERT INTO article (article_url, article_title, article_text, article_date, date_added) VALUES ({url}, {title}, {text}, {article_date}, {date_added})").on(
            'url ->   urlOpt.get,
            'title -> title.get,
            'text ->  (json \ "article_text").asOpt[String].get,
            'article_date ->  (json \ "article_date").asOpt[Date],
            'date_added ->    new Date()
          ).executeInsert[Option[Long]]()
        }
      }))

      // Store request
      (article_id, (json \ "request_text").asOpt[String], (json \ "request_text_surroundings").asOpt[String]) match {
        case (Some(aid), Some(text), Some(surround)) =>
          // If we have all parameters then insert
          val id = SQL"""INSERT INTO request
            (article_id, request_text, request_text_surroundings, date_asked)
            VALUES ($aid,$text,$surround,${new Date})""".executeInsert[Option[Long]]()
          id match {
            case Some(req) => Redirect(routes.API.singleArticle()+s"?id=$aid&req_id=$req")
            case _ => BadRequest("Something went wrong while inserting request")
          }
        case _ => BadRequest("Provide the fields article_id, request_text, request_text_surroundings. Instead of giving an article_id an article can be directly looked up/created by providing article_url, article_text and article_date.")
      }
    }.getOrElse(BadRequest("Expecting Json data in request body"))
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
