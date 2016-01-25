
require 'pg'


if ENV["RACK_ENV"] == "production"
  conn = PG.connect(
  dbname: ENV["POSTGRES_DB"],
  host: ENV["POSTGRES_HOST"],
  password:ENV["POSTGRES_PASS"],
  user:ENV["POSTGRES_USER"]
  )
else
conn = PG.connect(dbname: "killer-apps")



conn.exec("DROP TABLE IF EXISTS contact_data")



conn.exec("DROP TABLE IF EXISTS  emails CASCADE;")
conn.exec("DROP TABLE IF EXISTS  users CASCADE;")
conn.exec("DROP TABLE IF EXISTS  topics CASCADE;")
conn.exec("DROP TABLE IF EXISTS  post CASCADE;")
conn.exec("DROP TABLE IF EXISTS  comments CASCADE;")

  conn.exec(" CREATE TABLE emails (
     id 		 SERIAL PRIMARY KEY,
     email    	 VARCHAR UNIQUE NOT NULL,
     email_date  TIMESTAMP  DEFAULT CURRENT_TIMESTAMP
    );")

    conn.exec("CREATE TABLE users(
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
    );")


  conn.exec("CREATE TABLE topics (
    id 		 	  SERIAL PRIMARY KEY,
    topic_subject VARCHAR(255) ,
    topic_date 	  TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    topic_by      INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
    );")

   conn.exec("CREATE TABLE post(
     id      	   SERIAL PRIMARY KEY,
     post_title    VARCHAR(50),
     post_topic    VARCHAR(50),
     post_content  VARCHAR(1020) ,
     post_date 	   TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
     post_vote	   INT,
     post_by       INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
     topic_ref    INTEGER REFERENCES topics(id) ON DELETE CASCADE ON UPDATE CASCADE
    );")

    conn.exec("CREATE TABLE comments(
     id              SERIAL PRIMARY KEY,
     comment_content VARCHAR(1020),
     comment_date 	 TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
     comment_by	     INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
     comment_in	     INTEGER REFERENCES post(id) ON DELETE CASCADE ON UPDATE CASCADE
    );")


    end

