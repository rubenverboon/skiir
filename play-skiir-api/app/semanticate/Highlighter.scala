package semanticate

import play.api.libs.json.Json

import scala.language.postfixOps
import scala.math.min

case class Highlight(before: Int, after: Int, bolds: Seq[(Int,Int)]) {
  def toJson(text: String) = Json.obj(
    "outer" -> Json.arr(before, after),
    "bolds" -> Json.arr(bolds.map(t => Json.arr(t._1, t._2, text.substring(t._1, t._2)))),
    "snip" -> text.substring(Math.max(0,before), Math.min(after, text.size-1))
  )

  /**
   * Expand until word-boundaries
   * @param desiredExpansion Amount of expansion desired
   * @return
   */
  def expand(desiredExpansion: Int)(text: String): (Int,Highlight) = {
    (
      "[^\\w]+".r.findFirstMatchIn(text.drop(after)).map(_.end),
      "[^\\w]+".r.findFirstMatchIn(text.take(before).reverse).map(_.end)
    ) match {
      case _ if desiredExpansion <= 0 => (0, this)
      case (Some(a), Some(b)) if a+b < desiredExpansion =>
        Some(Highlight(before - b, after + a, bolds).expand(desiredExpansion - a - b)(text)).map(t => (t._1 + a + b, t._2)).get
      case (Some(a), _) if a < desiredExpansion =>
        Some(Highlight(before, after + a, bolds).expand(desiredExpansion - a)(text)).map(t => (t._1 + a, t._2)).get
      case (_, Some(b)) if b < desiredExpansion =>
        Some(Highlight(before - b, after, bolds).expand(desiredExpansion - b)(text)).map(t => (t._1 + b, t._2)).get
      case _ => (0, this)
    }
  }
}

object Highlighter {

  def mergeAndStretch(highlights: Seq[Highlight])(text: String, desiredLength: Int): Seq[Highlight] = {
    highlights
      // Stretch
      .map(h => h.expand(desiredLength/highlights.size - h.after + h.before)(text)._2)
      // Merge
      .foldRight(Seq.empty[Highlight])((c, list) => (list, c) match {
        case (prev :: rest, curr) if prev.before < curr.before && prev.after >= curr.before => {
//          println("\nprev.after < curr.before")
//          println("Prev: "+prev)
//          println("Curr: "+curr)
          Highlight(prev.before, curr.after, prev.bolds ++ curr.bolds) :: rest
        }
        case (prev :: rest, curr) => {
//          println("\nprev.after >= curr.before")
//          println("Prev: " + prev)
//          println("Curr: " + curr)
          curr :: prev :: rest
        }
        case (Nil, curr) => curr :: Nil
      })
  }

  def highlight(text: String, words: Iterable[String]): Seq[Highlight] = {
    val matches = for {
      w <- words
      loc <- Range(0, text.length, 1000) // 1000 is the search range of Bitap
    } yield (w, new Bitap(text, w, loc).locate())

    val highlights = matches.filter(_._2 >= 0).map { case (w, pos) =>
      Highlight(
        pos,
        pos + w.size,
        Seq((pos, pos+w.size))
      )
    } toList

    mergeAndStretch(highlights)(text, 250)
  }
  
  /**
   * Levenstein in 4 lines. Borrowed from:
   * @see https://gist.github.com/tixxit/1246894
   */
  def editDist[A](a: Iterable[A], b: Iterable[A]) =
    ((0 to b.size).toList /: a)((prev, x) =>
      (prev zip prev.tail zip b).scanLeft(prev.head + 1) {
        case (h, ((d, v), y)) => min(min(h + 1, v + 1), d + (if (x == y) 0 else 1))
      }) last

}
