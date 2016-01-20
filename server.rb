require "bcrypt"

module Forum
	class Server < Sinatra::Base

		get '/' do
			erb :index
		end

		get '/fourm' do
		erb :fourm
	  end

	end
end