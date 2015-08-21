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

  describe "GET index" do
    before :each do
      Link.generate("GUB0100143", @valid_date).save
      Link.generate("GUB0100143", @valid_date).save
      Link.generate("GUB0100144", @valid_date).save
      Link.generate("GUB0100145", @valid_date).save
    end

    it "should require authentication" do
      get :index, package_name: "GUB0100143"
      expect(json['links']).to be_nil
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(403)
    end

    it "should return list of links for provided package name" do
      get :index, api_key: @api_key, package_name: "GUB0100143"
      expect(json['links'].count).to eq(2)
      get :index, api_key: @api_key, package_name: "GUB0100144"
      expect(json['links'].count).to eq(1)
    end
  end

  describe "GET link" do
    before :each do
      MetsPackage.sync
      @valid_link1 = Link.generate("GUB0100143", @valid_date); @valid_link1.save
      @valid_link2 = Link.generate("GUB0100143", @valid_date); @valid_link2.save
      @invalid_link1 = Link.generate("GUB0100144", @valid_date); @invalid_link1.save
      @invalid_link2 = Link.generate("GUB0100145", @invalid_date); @invalid_link2.save(validate: false)
    end

    it "should return link redirection data for valid link" do
      get :show, link_hash: @valid_link1.link_hash
      expect(json['link']).to_not be_nil
      expect(response.status).to eq(200)
      get :show, link_hash: @valid_link2.link_hash
      expect(json['link']).to_not be_nil
      expect(response.status).to eq(200)
    end

    it "should return error for link with expired date" do
      get :show, link_hash: @invalid_link2.link_hash
      expect(json['link']).to be_nil
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(404)
    end

    it "should return error for link with no package" do
      get :show, link_hash: @invalid_link1.link_hash
      expect(json['link']).to be_nil
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(404)
    end
  end

  describe "DELETE link" do
    before :each do
      @link = Link.generate("GUB0100143", @valid_date); @link.save
    end

    it "should require authentication" do
      get :destroy, link_hash: @link.link_hash
      expect(json['link']).to be_nil
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(403)
    end

    it "should remove existing link" do
      expect(Link.count).to eq(1)
      get :destroy, api_key: @api_key, link_hash: @link.link_hash
      expect(json['link']).to_not be_nil
      expect(json['error']).to be_nil
      expect(Link.count).to eq(0)
      expect(response.status).to eq(200)
    end

    it "should give error on non-existing link" do
      expect(Link.count).to eq(1)
      get :destroy, api_key: @api_key, link_hash: "do-not-exist"
      expect(json['link']).to be_nil
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(404)
      expect(Link.count).to eq(1)
    end
  end
end
