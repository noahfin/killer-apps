require "bcrypt"
require 'date'
module Forum
	class Server < Sinatra::Base
		attr_reader :post_id
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
      erb :fourm
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
			conn = PG.connect(dbname: "killer-apps")
      
    		#@post = db.exec_params("SELECT * FROM post JOIN comments ON .house_id  = houses.id WHERE house_id = #{id}" ).to_a
         
       # @post = conn.exec_params("SELECT * FROM post ;").to_a
     
      

			erb :show

		end
		post '/post' do

			topic = params["topic"]
			title = params["title"]
			post_id = params["post"]
      message = params["message"]
      conn = PG.connect(dbname: "killer-apps")
      	post_id = conn.exec_params(
    		"INSERT INTO post (post_title, post_content, post_by, post_topic	) VALUES ($1, $2, $3, $4  )RETURNING id;",[title, message, current_user['id'], topic])
         post_id =  post_id.first["id"].to_i  
        @post = conn.exec_params("SELECT * FROM post WHERE id = $1", [post_id]).to_a
     
      conn.exec_params(
    		"INSERT INTO topics (topic_subject, topic_by  ) VALUES ($1, $2  );",[topic, current_user['id']]  )
    
     erb :show
		end
		post '/comment' do 
			  comment = params["comment"]
			   conn = PG.connect(dbname: "killer-apps")
			 #  user = conn.exec_params("SELECT * FROM users WHERE email = $1",[email]).first
      	conn.exec_params(
    		"INSERT INTO comments (comment_content , comment_by, comment_in) VALUES ($1, $2 );",[comment,  current_user['id'], post_id])

		end

		get '/fourm' do
		erb :fourm
	  end

	end
end