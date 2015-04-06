# SkiIR API
=================================

First you will need a Postgres database. 
Install the [Heroku Postgres app](http://postgresapp.com/).
Start the application, and click `Open psql` when this option appears in the window. 
Now create a new database by typing `CREATE DATABASE skiir;` and hit `[enter]`.

To start the API you need to do the following steps:

You will need an Alchemy API key, which you can retrieve from [Getting started with AlchemyAPI](http://www.alchemyapi.com/developers/getting-started-guide).

The following instructions are for Macintosh systems, where [brew](http://brew.sh) is installed.

````bash
brew install sbt # or apt-get install sbt
cd <root>/play-skiir-api # location where this README is too
cp conf/application.example.conf conf/application.conf
nano conf/application.conf # or use Vim or whatever
````

Then, when you have edited the application.conf file to contain your database credentials and Alchemy key, run:

````bash
sbt run # Assuming you have sbt
````

Now the API will be running at [http://localhost:9000](http://localhost:9000). At least the following end-points exist:

````
# Basic API
GET            /requests                                   get all annotation requests.
POST           /requests                                   add a new request.
GET            /requests/:rid                              get a single annotation request by id.
POST           /requests/:rid/annotations                  set a new annotations for a request.
POST           /requests/:rid/annotations/:eid/vote        vote (+1) for a specific annotation (belonging to a specific request.)
GET            /requests/:rid/relatedArticles              get related articles for a request (based upon text surroundings).
GET            /requests/:rid/annotations                  get all annotations for a request.

GET            /articles                                   get all articles
GET            /articles/single                            get a single article.
GET            /articles/:id                               get a article by an id.
POST           /articles/:id/requests                      add a request for annotation for a specific article.
GET            /articles/related/:id                       get related articles for this article (based upon the whole article text).

#semantic tools
GET            /explain/:text                              lets you retrieve DBPedia entries for the text.
GET            /crawl/:url                                 crawls the provided url for entities and concepts, and stores these internally.
GET            /crawl                                      same as above, different syntax.

# Map static resources from the /public folder to the /assets URL path
GET            /assets/*file                               crawls all articles provided in the file.

````
