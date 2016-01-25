require "bcrypt"
require 'date'
require 'redcarpet'
module Forum
	class Server < Sinatra::Base
		
		set :method_orverride, true
		enable :sessions
		#conn = PG.connect(dbname: "killer-apps")
		def current_user      
     conn = PG.connect(dbname: "users")
     @current_user ||= conn.exec_params("SELECT * FROM USERS WHERE ID = $1",[session["user_id"]] ).first
    end

    def make_markdown(content)
    	options ={
			:autolink => true,
			:space_after_headers => true,
			:no_intra_emphasis => true
			}
			markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
			markdown.render(content)
		end
		 if ENV["RACK_ENV"] == "production"
				conn = PG.connect(
  			dbname: ENV["POSTGRES_DB"],
  			host: ENV["POSTGRES_HOST"],
  			password:ENV["POSTGRES_PASS"],
  			user:ENV["POSTGRES_USER"]
			)
			else

    	@@conn ||= PG.connect(dbname: "killer-apps")
     end


    	def gravatar_url(id)
    		@email = @@conn.exec_params("SELECT email FROM users WHERE id = $1",[id]).first
    		@stripped_email = @email['email'].strip
    		@downcased_email = @stripped_email.downcase
    		hash = Digest::MD5.hexdigest(@downcased_email)
    		'http://gravatar.com/avatar/' + hash.to_s
    	end

  #   	def comment_images(comments)
  #   	@image_array = []
		# 	comments.each do |post|
			
		# 		@image_array.push(gravatar_url(post['post_by'].to_i))
		# 	end
		# 	@image_array
		# end

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
    	
      new_user =	@@conn.exec_params(
    		"INSERT INTO users (fname, lname, email, city, state, terms, password) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id;",[fname, lname, email, city, state, terms, password] )
    	@contact_submitted = true
      session["user_id"] = new_user.first["id"].to_i    
      erb :fourm
    end

    post '/login' do
			password = params["password"]
      email = params["email"]
      user = @@conn.exec_params("SELECT * FROM users WHERE email = $1",[email]).first
        
      user_password = BCrypt::Password.new(user["password"])
     
      if user_password == password
        session["user_id"] = user["id"].to_i  
        redirect '/fourm' 
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
      if current_user == nil || current_user['id'].to_i < 1
      	'<a href="/login">You need to signup or login to post</a>'
      else
      post_id = @@conn.exec_params(
    		"INSERT INTO post (post_title, post_content, post_by, post_topic) VALUES ($1, $2, $3, $4  )RETURNING id;",[title, message, current_user['id'], topic])
         post_id =  post_id.first["id"].to_i  
        @post = conn.exec_params("SELECT * FROM post WHERE id = $1", [post_id]).to_a
     
      @@conn.exec_params(
    		"INSERT INTO topics (topic_subject, topic_by  ) VALUES ($1, $2  );",[topic, current_user['id']]  )

      
     redirect '/post/' + post_id.to_s 
   end
		end

		get '/post/:id' do 
			 post_id = params["id"].to_i
			@post = @@conn.exec_params("SELECT * FROM post WHERE id = #{post_id};").to_a
      @comments = @@conn.exec_params("SELECT * FROM comments WHERE comment_in = $1",[post_id]).to_a
      	@email = gravatar_url(@post[0]['post_by'])
      	
      	@id_array = []
      	@comment_array = []
      	@comments.each do |comment|
				@id_array.push( comment['comment_by'].to_i) 
				
			end
			@comment_names= []

			@id_array.each_with_index do |id, i|
			@comment_names.push(@@conn.exec_params("SELECT (fname, lname) FROM users WHERE id = $1",[@id_array[i]]).first)
			@comment_array.push(gravatar_url(@id_array[i])).first 
			@email = gravatar_url(@post[0]['post_by'])
			# @id_array.each do |id|
			
      	
			end

			@id_array = []
			@post.each do |post|
				@id_array.push( post['post_by'].to_i) 
			end
			@name = []
			@id_array.each do |id|
			 @name.push(@@conn.exec_params("SELECT (fname, lname) FROM users WHERE id = $1",[id]).first)
			end
        	
			#@comments = conn.exec_params("SELECT * FROM comments JOIN post ON comment.comment_in = post.id WHERE comment_in = #{post_id}" ).to_a
		
	
			erb :show
		end
     ########################################################################
		get '/user/:id' do
			post_id = params["id"]
			@post = @@conn.exec_params("SELECT * FROM post JOIN users ON post.post_by = users.id WHERE post_by = $1",[	post_id ] ).to_a
			 @email = gravatar_url(@post[0]['post_by'])
			erb :fourm
		end   #= $1",[session["user_id"]] 

		post '/comment' do 
			if current_user == nil || current_user['id'].to_i < 1
      	'<a href="/login">You need to signup or login to commentt</a>'
      else
			  comment = params["message"]
			  post_id = params["post_id"].to_i
			 #  user = conn.exec_params("SELECT * FROM users WHERE email = $1",[email]).first
      	@@conn.exec_params(
    		"INSERT INTO comments (comment_content , comment_by, comment_in) VALUES ($1, $2, $3 );",[comment,  current_user['id'], post_id])
      	'Your comment was posted sucessfuly' +  '<a href="/post/' + post_id.to_s + '">View</a>' 
		  end
	  end

		get '/fourm' do
			@post = @@conn.exec_params("select * from post;").to_a
			@id_array = []
			@image_array = []
			@post.each do |post|
				@id_array.push( post['post_by'].to_i) 
				@image_array.push(gravatar_url(post['post_by']))
			end
			@name = []
			@id_array.each do |id|
			 @name.push(@@conn.exec_params("SELECT (fname, lname) FROM users WHERE id = $1",[id]).first)
			end


		erb :fourm
	  end

	  get '/topic/:topic' do
	  	topic = params['topic']
			@post =  @@conn.exec_params("SELECT * FROM post WHERE post_topic LIKE $1",[topic] )
			erb :fourm

	  end

	  get '/edit/:id' do
	  	post_id = params["id"].to_i
			@post = @@conn.exec_params("SELECT * FROM post WHERE id = $1;",[post_id]).to_a
	  	erb :edit
	  end


	  get '/delete/:id' do
	  	 post_id = params["id"].to_i
			@post =  @@conn.exec_params("SELECT * FROM post WHERE id = $1;",[post_id]).to_a
		 @comments =@@conn.exec_params("SELECT * FROM comments WHERE comment_in = $1",[post_id]).to_a		 	
	  	erb :delete
	  end
	  post '/delete/:id' do
	  	post_id = params['id'].to_i
	    @post = @@conn.exec_params("SELECT * FROM post WHERE id = #{post_id};").to_a
			   if @post[0]['post_by'] == current_user['id']
			 @@conn.exec_params("DELETE FROM POST WHERE id = $1 ",[post_id])
			 'you were able to delete'
			else 
				'You were not allowed to delete'

		  end
	end




	  post '/edit/:id' do
	  	post_id = params['id'].to_i
	  	topic = params["topic"]
			title = params["title"]
      message = params["message"]

      if  topic.length < 1 && title.length <1 && message.length <1
      	"Data error"
        elsif topic.length < 1 && title.length <1 && message.length >= 1
        'message updated'   	
      	 @@conn.exec_params("UPDATE post SET post_content =$1 WHERE id = $2;",[ message,post_id ])
      	elsif  topic.length < 1 && title.length > 0 && message.length > 1
      		'message and title updated'
      		 @@conn.exec_params("UPDATE post SET post_content =$1, post_title = $2 WHERE id = $3;",[ message, title, post_id ])
      	elsif  topic.length > 1  && title.length  < 1  && message.length > 1	 
      		'topic and message updated'
      		 @@conn.exec_params("UPDATE post SET post_content =$1, post_topic = $2 WHERE id = $3;",[ message, topic, post_id ])
      	elsif  topic.length > 0  && title.length > 0  && message.length > 1	 
      		 @@conn.exec_params("UPDATE post SET post_content =$1, post_topic = $2, post_title = $3  WHERE id = $4;",[ message, topic, title, post_id ])
      		 'topic message and title were updated'
      	
      		 elsif topic.length > 1 && title.length <1 && message.length < 1      		 	
          @@conn.exec_params("UPDATE post SET post_topic =$1 WHERE id = $2;",[ topic,post_id ])  	
      elsif topic.length < 1 && title.length >1 && message.length < 1
        'title updated'   	
      	 @@conn.exec_params("UPDATE post SET post_title =$1 WHERE id = $2;",[ title,post_id ])
      else
      	"Error"

      	end

 			#{}"topic:" + topic.to_s + "title:" + title.to_s + "message:" + message.to_s

     redirect '/post/'  + post_id.to_s 



	  end
	  


	end
end