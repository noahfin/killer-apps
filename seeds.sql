-- remove any records and start the id sequence back to 1
DROP TABLE IF EXISTS  users CASCADE;
DROP TABLE IF EXISTS  topics CASCADE;
DROP TABLE IF EXISTS  post CASCADE;
DROP TABLE IF EXISTS  comments CASCADE;



CREATE TABLE users(
  id       SERIAL PRIMARY KEY,
  fname    VARCHAR NOT NULL,
  lname    VARCHAR NOT NULL,
  image    VARCHAR(255),
  email    VARCHAR UNIQUE NOT NULL,
  password VARCHAR(255),
  city     VARCHAR(255),
  state    VARCHAR,
  terms    BOOLEAN NOT NULL,
  sup_user BOOLEAN 
);


CREATE TABLE topics (
id 		 	  SERIAL PRIMARY KEY,
topic_subject VARCHAR(255) NOT NULL,
topic_date 	  DATE NOT NULL,
topic_by      INTEGER REFERENCES users(id)
);

CREATE TABLE post(
 id      SERIAL PRIMARY KEY,
 post_title   VARCHAR(50),
 post_content VARCHAR(510) NOT NULL,
 post_date 	  TIMESTAMP  NOT NULL,
 post_vote	  INT,
 post_by      INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
 post_topic   INTEGER REFERENCES topics(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE comments(
 comment_id      SERIAL PRIMARY KEY,
 comment_date 	 TIMESTAMP NOT NULL,
 comment_by	     INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
 comment_in	 INTEGER REFERENCES post(id) ON DELETE CASCADE ON UPDATE CASCADE

);

