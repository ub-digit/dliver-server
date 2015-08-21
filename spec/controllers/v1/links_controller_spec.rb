require "rails_helper"

describe V1::LinksController do

  before :each do
    login_users
    @api_key = APP_CONFIG["api_key_users"].first["api_key"]
    @valid_date = (Time.now + 2.days).strftime("%Y-%m-%d")
    @invalid_date = (Time.now - 2.days).strftime("%Y-%m-%d")
  end

  describe "POST create" do
    context "with valid parameters and api_key" do
      it "should return a link object with link_hash" do
        post :create, api_key: @api_key, link: {package_name: "GUB0100143", expire_date: @valid_date}
        expect(json['link']['link_hash']).to_not be nil
        expect(json['link']['link_hash']).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
        expect(response.status).to eq 201
      end
    end
    context "With invalid expire_date" do
      it "should return an error object" do
        post :create, api_key: @api_key, link: {package_name: "GUB0100143", expire_date: @invalid_date}
        expect(json['error']).to_not be nil
        expect(json['link']).to be nil
        expect(response.status).to eq 422
      end
    end
    context "With missing expire_date" do
      it "should return an error object" do
        post :create, api_key: @api_key, link: {package_name: "GUB0100143"}
        expect(json['error']).to_not be nil
        expect(json['link']).to be nil
        expect(response.status).to eq 422
      end
    end
    context "With missing package_name" do
      it "should return an error object" do
        post :create, api_key: @api_key, link: {expire_date: @valid_date}
        expect(json['error']).to_not be nil
        expect(json['link']).to be nil
        expect(response.status).to eq 422
      end
    end
    context "with valid parameters and authorized user" do
      it "should return a user object with id" do
        request.env["HTTP_AUTHORIZATION"] = "Token #{@admin_user_token}"
        post :create, link: {package_name: "GUB0100143", expire_date: @valid_date}
        expect(json['link']['link_hash']).to_not be nil
        expect(json['link']['link_hash']).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
        expect(response.status).to eq 201
      end
    end

  end
end
