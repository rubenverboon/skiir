package models

import java.util.Date

case class Request(id: Long, article_id: Long, text_surroundings: String, text: String, date_asked: Date) {

}

case class Article(id: Long, url: String, title: String, text: String, date: Date, date_added: Date) {

}

case class Entity(typ: String, relevance: Double, count: Int, text: String)

case class ArticleEntity(`type`: String,
                         relevance: Float,
                         count: Int,
                         text: String,
                         entity_name: String,
                         dbpedia: Option[String]
                        )

