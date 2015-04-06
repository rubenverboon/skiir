package models

import java.util.Date

import anorm.Row
import play.api.libs.json.{JsValue, Json}

case class Request(id: Long, article_id: Long, text_surroundings: String, text: String, date_asked: Option[Date]) {
  def toJson = Json.obj(
    "id"          -> id,
    "article_id"  -> article_id,
    "text"        -> text,
    "text_surroundings" -> text_surroundings,
    "date_asked"  -> date_asked
  )
  def actionsJson = Json.obj(
    "actions" -> Json.obj(
      "self" -> controllers.api.routes.Requests.getRequestById(id).toString,
      "annotate" -> controllers.api.routes.Annotations.addAnnotation(id).toString,
      "relatedArticles" -> controllers.api.routes.Articles.getRelatedArticlesOfRequest(id).toString,
      "annotations" -> controllers.api.routes.Annotations.getAnnotationOfRequest(id).toString
    )
  )
}

object Request {
  def fromRow(row: Row) = Request(
    row[Long]("request_id"),
    row[Long]("article_id"),
    row[String]("request_text_surroundings"),
    row[String]("request_text"),
    row[Option[Date]]("date_asked")
  )
}

case class Article(id: Long, url: String, title: String, text: String, date: Option[Date], date_added: Option[Date]) {
  def toJson = Json.obj(
    "id"         -> id,
    "url"        -> url,
    "title"      -> title,
    "text"       -> text,
    "date"       -> date,
    "date_added" -> date_added
  )
}

object Article {
  def fromRow(row: Row) = Article(
    row[Long]("article_id"),
    row[String]("article_url"),
    row[String]("article_title"),
    row[String]("article_text"),
    row[Option[Date]]("article_date"),
    row[Option[Date]]("date_added")
  )
}

case class Annotation(id: Long, request_id: Long, article_id: Long, answer: String, answered: Option[Date], votes: Int, references: JsValue) {
  def toJson = Json.obj(
    "id"            -> id,
    "request_id"    -> request_id,
    "article_id"    -> article_id,
    "answer"        -> answer,
    "date_answered" ->answered,
    "votes"         -> votes,
    "references"    -> references
  )
  def actionsJson = Json.obj(
    "actions" -> Json.obj(
      "vote" -> controllers.api.routes.Annotations.voteAnnotation(request_id, id).toString
    )
  )
}

object Annotation {
  def fromRow(row: Row) = Annotation(
    row[Long]("annotation_id"),
    row[Long]("request_id"),
    row[Long]("article_id"),
    row[String]("annotation_answer"),
    row[Option[Date]]("date_answered"),
    row[Int]("votes"),
    Json.parse(row[String]("refs"))
  )
}

case class Entity(typ: String, relevance: Double, count: Int, text: String)

trait ArticleLink {
  def `type`: String
  def relevance: Float
  def count: Int
  def text: String
  def entity_name = text
  def dbpedia: Option[String]
}

case class ArticleEntity(`type`: String,
                         relevance: Float,
                         count: Int,
                         text: String,
                         override val entity_name: String,
                         dbpedia: Option[String]
                          ) extends ArticleLink

case class ArticleConcept(text: String,
                          relevance: Float,
                          dbpedia: Option[String]) extends ArticleLink {
  override def `type`: String = "Concept"
  override def count: Int = 1
}

