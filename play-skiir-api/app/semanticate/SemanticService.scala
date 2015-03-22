package semanticate

import java.security

import com.likethecolor.alchemy.api._
import com.likethecolor.alchemy.api.call._
import com.likethecolor.alchemy.api.call.`type`.CallTypeText
import com.likethecolor.alchemy.api.entity._
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
      Logger.debug("Calling Alchemy API")
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
    dbp.map(jsval => Entity(concept, Some(jsval)))
  }

  private def dbPediaByTerm(term: String): Future[JsValue] = {
    WS.url(s"http://dbpedia.org/sparql").withQueryString(
      "query" -> s"""SELECT DISTINCT ?entity ?label ?score1
                     WHERE{
                       ?entity ?p ?label.
                       ?label <bif:contains> "'${term.replaceAll("[^a-zA-Z0-9\\s]", "-")}'" OPTION(score ?score1).
                       FILTER (?p=<http://www.w3.org/2000/01/rdf-schema#label>).
                       ?entity a ?type.
                       FILTER isIRI(?entity).
                     } ORDER BY desc(?score1)""",
      "format" -> "json"
    ).get().map {
      case r if r.status == 200 => Json.parse(r.body)
      case r => throw new RuntimeException(r.body)
    }
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
    ).get().map {
      case r if r.status == 200 => Json.parse(r.body)
      case r => throw new RuntimeException(r.body)
    }
  }
}
