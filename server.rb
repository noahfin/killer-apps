require "bcrypt"

module Forum
	class Server < Sinatra::Base
		set :method_orverride, true
		enable :sessions
		#conn = PG.connect(dbname: "killer-apps")
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
         erb :index
        else 
         '<a href="/login">Wrong password go back to sgin in</a>'
        end

		end

		get '/fourm' do
		erb :fourm
	  end

	end
end