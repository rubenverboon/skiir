name := """play-skiir-api"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.1"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws,
  "postgresql" % "postgresql" % "9.1-901-1.jdbc4",
  "org.julienrf" %% "play-jsonp-filter" % "1.2",
  "com.likethecolor" % "alchemy" % "1.1.6"
)