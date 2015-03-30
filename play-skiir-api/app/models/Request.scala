package models

import java.util.Date

case class Request(id: Long, article_id: Long, text_surroundings: String, text: String, date_asked: Date) {

}

case class Article(id: Long, url: String, title: String, text: String, date: Date, date_added: Date) {

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

