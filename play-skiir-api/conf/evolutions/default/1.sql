# Initial database

# --- !Ups

CREATE TABLE article (
    article_id bigserial primary key,
    article_url varchar(100) NOT NULL,
    article_title varchar(40) NOT NULL,
    article_text text NOT NULL,
    article_date timestamp default NULL,
    date_added timestamp default NULL
);

CREATE TABLE request (
  request_id bigserial primary key,
  article_id BIGINT NOT NULL REFERENCES article (article_id),
  request_text_surroundings text NOT NULL,
  request_text text NOT NULL,
  date_asked timestamp default NULL
);

CREATE TABLE annotation (
  annotation_id bigserial primary key,
  request_id BIGINT NOT NULL REFERENCES request (request_id),
  article_id BIGINT NOT NULL REFERENCES article (article_id),
  annotation_answer text NULL,
  date_answered timestamp default NULL,
  votes INT DEFAULT 0
);

# --- !Downs

DROP TABLE article;
DROP TABLE request;
DROP TABLE annotation;