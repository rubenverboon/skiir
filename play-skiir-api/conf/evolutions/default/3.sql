# Add annotation references

# --- !Ups

ALTER TABLE annotation ADD COLUMN refs TEXT default NULL;

# --- !Downs

ALTER TABLE annotation DROP COLUMN refs;