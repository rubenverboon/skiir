package models

import java.util.Date

/**
 * Created by rubenverboon on 21/03/15.
 */
case class Request(id: Long, val article_id: Long, val text_surroundings: String, val text: String, val date_asked: Date) {

}

case class Article(val id: Long, val url: String, val title: String, val text: String, val date: Date, val date_added: Date) {

}

