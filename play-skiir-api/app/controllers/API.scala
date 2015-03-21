package controllers

import java.util.Date

import anorm._
import play.api.Play.current
import play.api.db.DB
import play.api.libs.json.Json._
import play.api.libs.json.{JsArray, Json}
import play.api.mvc._

object API extends Controller {

  def articles = Action {
    Ok(JsArray(getArticles()))
  }

  def requests = Action {
    Ok(getRequests())
  }

  def getArticles(id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = id match {
        case Some(aid) => SQL("SELECT * FROM article WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM article")
      }
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

  def singleArticle(id: Long) = Action {
    val resultList = getArticles(Some(id))
    Ok(resultList(0) ++ Json.obj(
      "requests" -> getRequests(Some(id)),
      "annotations" -> getAnnotations(Some(id))
    ))
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

}
