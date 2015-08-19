require 'rails_helper'


describe V1::ApiController, :type => :controller do
	before :each do
		@api_key = APP_CONFIG["api_key_users"].first["api_key"]
	end

end
