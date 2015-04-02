# Add entities

# --- !Ups

CREATE TABLE entity (
  entity_id bigserial primary key,
  entity_name VARCHAR(100) NOT NULL,
  dbpedia_url varchar(200) NULL,
  type varchar(100) DEFAULT NULL,
  UNIQUE(entity_name,type)
);

CREATE TABLE entity_article (
  article_id BIGINT NOT NULL REFERENCES article (article_id),
  entity_id BIGINT NOT NULL REFERENCES entity (entity_id),
  relevance DECIMAL(7,6),
  count INT DEFAULT 1,
  text VARCHAR(100),
  PRIMARY KEY( article_id, entity_id)
);

# --- !Downs

DROP TABLE entity_article;
DROP TABLE entity;