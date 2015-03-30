package controllers

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.util.Date

import anorm.SqlParser._
import anorm._
import models.ArticleEntity
import org.joda.time.LocalDate
import play.api.Play.current
import play.api.db.DB
import play.api.libs.json._
import play.api.libs.ws.WS
import play.api.mvc.{Action, Controller}
import play.api.{Logger, Play}
import semanticate.SemanticServiceImpl

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import scala.io.Source
import scala.util.{Try, Success, Failure}

object Crawler extends Controller {

  import java.security.MessageDigest

  def md5(s: String) = {
    MessageDigest.getInstance("MD5").digest(s.getBytes).map("%02x".format(_)).mkString
  }

  val alchemyKey = Play.current.configuration.getString("alchemy.key").filterNot(_ == "undefined").getOrElse({
    Logger.warn("Please add a alchemy.key property in your application.conf")
    "wrongkey"
  })

  def explain(text: String) = Action.async {
    val s = new SemanticServiceImpl()
    s.findConcepts(text).flatMap(l =>
      Future.sequence(l.map(c => s.explain(c)))
    ).map(l => Json.obj(
      l.map(e =>
        e.concept.getConcept -> Json.toJsFieldJsValueWrapper(e.details.getOrElse(JsNumber(1)))).toSeq:_*
      )
    ).map(Ok(_))
  }

  def crawl(urlOpt: String) = Action.async { req =>
    val url = Some(urlOpt).filterNot(_.isEmpty).orElse(req.queryString.get("url").map(_.head)).getOrElse("sjaars...")

    val result = cacheRead(md5(url)+".json").fold(
      WS.url("http://access.alchemyapi.com/calls/url/URLGetRankedNamedEntities").withQueryString(
        "url" -> url,
        "apikey" -> alchemyKey,
        "outputMode" -> "json",
        "showSourceText" -> "1"
      ).get().map(r => {
        cacheWrite(md5(url)+".json", r.json)
        r.json
      })
    )(json => Future.successful(json))

    val r = result.map(json => DB.withConnection { implicit c =>
      val dbUrl = (json \ "url").as[String].take(API.articleUrlLength)

      // Get or insert article
      val article_id = SQL("SELECT article_id FROM article WHERE article_url LIKE {url}").on('url -> dbUrl).as(scalar[Long].singleOpt).orElse {
        // Insert the article
        SQL("INSERT INTO article (article_url, article_title, article_text, article_date, date_added) VALUES ({url}, {title}, {text}, {article_date}, {date_added})").on(
          'url -> dbUrl,
          'title -> url.split('/').last.replace("-"," ").take(API.articleTitleLength),
          'text -> (json \ "text").as[String],
          'article_date ->  LocalDate.parse(url.substring(39,49)).toDateTimeAtStartOfDay.toDate(),
          'date_added ->    new Date()
        ).executeInsert[Option[Long]]()
      }

      // Store entities
      (json \ "entities").as[List[ArticleEntity]].map(ae => {
        // Find or insert entity
        val entity_id = SQL("SELECT entity_id FROM entity WHERE (entity_name ILIKE {name} AND type ILIKE {type}) OR dbpedia_url LIKE {dbpedia}").on(
          'name -> ae.text,
          'dbpedia -> ae.dbpedia,
          'type -> ae.`type`
        ).as(scalar[Long].singleOpt).orElse(
          // Not found, so insert
          SQL"""INSERT INTO
                entity (entity_name,dbpedia_url,type) VALUES
                (${ae.entity_name},${ae.dbpedia},${ae.`type`})""".executeInsert[Option[Long]]()
        )

        // Insert links
        Try(
          SQL"""INSERT INTO entity_article
              (article_id,entity_id,relevance,count,text) VALUES
              ($article_id, $entity_id,${ae.relevance},${ae.count},${ae.text})""".executeInsert[Option[Long]]()
        )
      })
    })

    r.onFailure {
      case e =>
        println(e)
        e.printStackTrace()
    }

    result.map(Ok(_))
  }

  def cacheRead(file: String): Option[JsValue] = {
    val f = new File(file)
    Try(Source.fromFile(file).mkString).map(Json.parse).toOption
  }

  def cacheWrite(file: String, json: JsValue) = {
    Files.write(Paths.get(file), json.toString().getBytes(StandardCharsets.UTF_8))
  }

  // JSON parsing of Alchemy entities
  implicit val entityReads = new Reads[ArticleEntity] {
    def reads(js: JsValue): JsResult[ArticleEntity] = {
      Try(ArticleEntity(
        (js \ "type").as[String],
        (js \ "relevance").asOpt[String].map(_.toFloat).getOrElse(0),
        (js \ "count").asOpt[String].map(_.toInt).getOrElse(0),
        (js \ "text").as[String],
        (js \ "disambiguated" \ "name").asOpt[String].getOrElse((js \ "text").as[String]),
        (js \ "disambiguated" \ "dbpedia").asOpt[String]
      )) match {
        case Success(e: ArticleEntity) => JsSuccess(e)
        case Failure(t) => {
          JsError.apply(t.getMessage + "\n" + t.getStackTrace)
        }
      }
    }
  }
}