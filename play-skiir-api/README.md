# SkiIR API
=================================

First you will need a Postgres database. 
Install the [Heroku Postgres app](http://postgresapp.com/).
Start the application, and click `Open psql` when this option appears in the window. 
Now create a new database by typing `CREATE DATABASE skiir;` and hit `[enter]`.

To start the API you need to do the following steps:

````bash
brew install sbt # or apt-get install sbt
cd <root>/play-skiir-api # location where this README is too
cp conf/application.example.conf conf/application.conf
nano conf/application.conf # or use Vim or whatever
````

Then, when you have edited the application.conf file to contain your database credentials, run:

````bash
sbt run # Assuming you have sbt
````

Now the API will be running at [http://localhost:9000](http://localhost:9000). At least the following end-points exist:

````
# Basic API
GET     /requests               Get all annotation requests
GET     /articles               Get all articles we have in the database
GET     /articles/:id           Get specific article, plus all annotations and annotation requests in database
# Semantic tools
GET     /explain/:text          Get DbPedia entries for all (AlchemyAPI) concepts in the given text
````