package semanticate

import java.io._
import java.security
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.{TransformerException, TransformerFactory}

import com.likethecolor.alchemy.api.Client
import com.likethecolor.alchemy.api.call.RankedConceptsCall
import com.likethecolor.alchemy.api.call.`type`.CallTypeText
import com.likethecolor.alchemy.api.entity.ConceptAlchemyEntity
import org.w3c.dom.Document
import play.api.Play.current
import play.api.cache.Cache
import play.api.libs.json.{JsValue, Json}
import play.api.libs.ws.WS
import play.api.{Logger, Play}
import scala.collection.JavaConversions._

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

case class Entity(concept: ConceptAlchemyEntity, details: Option[JsValue]) {}

trait SemanticService {
  def findConcepts(text: String): Future[List[ConceptAlchemyEntity]]
  def explain(concept: ConceptAlchemyEntity): Future[Entity]
}


class SemanticServiceImpl extends SemanticService {

  val alchemyKey = Play.current.configuration.getString("alchemy.key").filterNot(_ == "undefined").getOrElse({
    Logger.warn("Please add a alchemy.key property in your application.conf")
    "wrongkey"
  })
  val alchemy = new Client(alchemyKey)
  val hasher = security.MessageDigest.getInstance("MD5")

  override def findConcepts(text: String): Future[List[ConceptAlchemyEntity]] = Future {
    val docs = Cache.getOrElse("alchemy-json-"+hasher.digest(text.getBytes), 3600){
      val resp = alchemy.call(new RankedConceptsCall(new CallTypeText(text)))
      resp.iterator.toList
    }
    docs
  }

  override def explain(concept: ConceptAlchemyEntity): Future[Entity] = {
    val dbp = Option(concept.getDBPedia) match {
      case Some(url) => dbPediaByUrl(url)
      case _ => dbPediaByTerm(concept.getConcept)
    }
    dbp.map(jsval => {
      println(jsval)
      Entity(concept, Some(jsval))
    })
  }

  // utility method
  private def getStringFromDocument(doc: Document): String = {
    try {
      val domSource = new DOMSource(doc)
      val writer = new StringWriter()
      val result = new StreamResult(writer)

      val tf = TransformerFactory.newInstance()
      val transformer = tf.newTransformer()
      transformer.transform(domSource, result)

      writer.toString
  } catch {
      case ex: TransformerException => ex.printStackTrace()
        throw new RuntimeException("Something went wrong")
    }
  }

  private def dbPediaByTerm(term: String): Future[JsValue] = {
    WS.url(s"http://dbpedia.org/sparql").withQueryString(
      "query" -> s"""PREFIX dbp: <http://dbpedia.org/resource/>
                     PREFIX dbp2: <http://dbpedia.org/ontology/>

                     SELECT ?abstract
                     WHERE {
                        dbp:${term.replaceAll("[^a-zA-Z0-9\\s]", "-")} dbp2:abstract ?abstract .
                        FILTER langMatches(lang(?abstract), 'en')
                     }""",
      "format" -> "json"
    ).get().map(resp => {
      println(resp.body)
      Json.parse(resp.body)
    })
  }

  private def dbPediaByUrl(url: String): Future[JsValue] = {
    WS.url(s"http://dbpedia.org/sparql").withQueryString(
      "query" -> s"""PREFIX dbp: <http://dbpedia.org/resource/>
                     PREFIX dbp2: <http://dbpedia.org/ontology/>

                     SELECT ?abstract
                     WHERE {
                        <$url> dbp2:abstract ?abstract .
                        FILTER langMatches(lang(?abstract), 'en')
                     }""",
      "format" -> "json"
    ).get().map(resp => {
      println(resp.body)
      Json.parse(resp.body)
    })
  }
}
