require "bcrypt"

module Forum
	class Server < Sinatra::Base
		set :method_orverride, true

		get '/' do
			erb :index
		end
		get '/signup' do
			erb :signup
		end
		get '/login' do
			erb :login
		end


		get '/fourm' do
		erb :fourm
	  end

	end
end