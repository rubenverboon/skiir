package controllers

import play.api.libs.json.{JsNumber, Json}
import play.api.mvc.{Action, Controller}
import semanticate.SemanticServiceImpl
import scala.concurrent.ExecutionContext.Implicits.global

import scala.concurrent.Future

object Crawler extends Controller {

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

}
