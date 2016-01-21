require "bcrypt"
require 'date'
module Forum
	class Server < Sinatra::Base
		set :method_orverride, true
		enable :sessions
		#conn = PG.connect(dbname: "killer-apps")
		def current_user      
     conn = PG.connect(dbname: "users")
     @current_user ||= conn.exec_params("SELECT * FROM USERS WHERE ID = $1",[session["user_id"]] ).first
    end

		get '/' do
			erb :index
		end
		get '/signup' do
			erb :signup
		end
		get '/login' do
			erb :login
		end
		
    post '/signup' do
    	fname  =  params["fname"]
    	lname  =  params["lname"]
    	email = params["email"]
    	city  =  params["city"]
    	state = params["state"]
    	terms = params["terms"]

    	password = BCrypt::Password.create(params["password"])
    	conn = PG.connect(dbname: "killer-apps")
      new_user =	conn.exec_params(
    		"INSERT INTO users (fname, lname, email, city, state, terms, password) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id;",[fname, lname, email, city, state, terms, password] )
    	@contact_submitted = true
      session["user_id"] = new_user.first["id"].to_i    
       "Thanks for siging up"
    end

    post '/login' do
			password = params["password"]
      email = params["email"]
      conn = PG.connect(dbname: "killer-apps")
      user = conn.exec_params("SELECT * FROM users WHERE email = $1",[email]).first
        
      user_password = BCrypt::Password.new(user["password"])
     
      if user_password == password
        session["user_id"] = user["id"].to_i  
         erb :fourm
        else 
         '<a href="/login">Wrong password go back to sgin in</a>'
        end

		end
		get '/show' do 
			erb :show

		end
		post '/post' do

			topic = params["topic"]
			title = params["title"]
			topic_by =  current_user
      message = params["message"]
      conn = PG.connect(dbname: "killer-apps")
      	conn.exec_params(
    		"INSERT INTO post (post_title, post_content, post_by	) VALUES ($1, $2, $3  );",[title, message, current_user['id']])

      conn.exec_params(
    		"INSERT INTO topics (topic_subject, topic_by  ) VALUES ($1, $2  );",[topic, current_user['id']]  )
     erb :show
		end

		get '/fourm' do
		erb :fourm
	  end

	end
end