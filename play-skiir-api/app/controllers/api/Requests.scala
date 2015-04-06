package controllers.api

import java.util.Date

import anorm._
import Articles._
import controllers.{api, Crawler}
import play.api.Play.current
import play.api.db.DB
import play.api.libs.json.{JsArray, JsValue, Json}
import play.api.mvc._
import scala.concurrent.ExecutionContext.Implicits.global

import scala.concurrent.Future


object Requests {
  val noJsonBody = api.Articles.noJsonBody

  def requests = Action {
    Ok(api.Requests.getRequests())
  }

  def getRequests(article_id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = article_id match {
        case Some(aid) => SQL("SELECT * FROM request WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM request")
      }
      val rows = query().map(models.Request.fromRow).map(req => req.toJson ++ req.actionsJson).toList
      JsArray(rows)
    }
  }

  def getRequestById(id: Long) = Action {
    DB.withConnection { implicit c =>
      SQL"""SELECT * FROM request WHERE request_id = $id"""().map(models.Request.fromRow).map(req => req.toJson ++ req.actionsJson)
        .headOption
        .map(r => Ok(r))
        .getOrElse(NotFound)
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
              "self" -> api.routes.Requests.getRequestById(req).toString,
              "article" -> api.routes.Articles.articleById(aid).toString,
              "annotate" -> api.routes.Annotations.addAnnotation(req).toString,
              "relatedArticles" -> api.routes.Articles.getRelatedArticlesOfRequest(req).toString
            )
          ))
          case _ => BadRequest("Something went wrong while inserting request")
        }
      case _ => BadRequest("Provide the fields article_id, request_text, request_text_surroundings. Instead of giving an article_id an article can be directly looked up/created by providing article_url, article_text and article_date.")
    }
  }
}
