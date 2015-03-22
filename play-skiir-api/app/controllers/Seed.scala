package controllers

import play.api.libs.ws.WS
import play.api.mvc.{Action, Controller}
import play.api.Play.current
import scala.concurrent.ExecutionContext.Implicits.global

object Seed extends Controller {

  def seed = Action.async {
    val req = WS.url(routes.API.addRequest().url)
      .withBody("""{
                   |"article_url": "https://hermanbanken.nl/2015/03/01/newrelic-causing-outofmemoryerror/",
                   |"article_title": "Newrelic Causing Outofmemoryerror",
                   |"article_text": "Dummy Lorum Ipsum Dolor Amet",
                   |"request_text": "Ipsum",
                   |"request_text_surroundings": "Lorum Ipsum Dolor"
                   |}""".stripMargin)
      .execute(routes.API.addRequest().method)
    req.map(_ => Ok("Seeded!"))
  }

}
