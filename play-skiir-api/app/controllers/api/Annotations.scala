package controllers.api

import java.util.Date

import anorm._
import controllers.api.Articles._
import models.Annotation
import play.api.Play.current
import play.api.db.DB
import play.api.libs.json.{Json, JsArray}
import play.api.mvc._

object Annotations {

  def getAnnotationOfRequest(request_id: Long) = Action {
    DB.withConnection { implicit c =>
      val query = SQL"""SELECT * FROM annotation WHERE request_id =${request_id}"""
      Ok(JsArray(query().map(Annotation.fromRow).map(a=>a.toJson ++ a.actionsJson).toList))
    }
  }

  def getAnnotations(article_id: Option[Long] = None) = {
    DB.withConnection { implicit c =>
      val query = article_id match {
        case Some(aid) => SQL("SELECT * FROM annotation WHERE article_id = {aid}").on('aid -> aid)
        case _ => SQL("SELECT * FROM article")
      }
      query().map(Annotation.fromRow).map(ann => ann.toJson ++ ann.actionsJson).toList
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
      Created(Json.obj(
        "actions" -> Json.obj(
          "siblings" -> controllers.api.routes.Annotations.getAnnotationOfRequest(rid).toString
        )
      ))
    } getOrElse noJsonBody
  }}

  def voteAnnotation(rid: Long, eid: Long) = Action { request => DB.withConnection { implicit c =>
    val rows = SQL"""UPDATE annotation SET votes = votes + 1 WHERE annotation_id = $eid""".executeUpdate()
    if(rows == 1)
      Ok("")
    else
      InternalServerError("Zero, or strictly more than one row, where voted on.")
  }}
}
