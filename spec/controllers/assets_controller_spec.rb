require 'rails_helper'

RSpec.describe AssetsController, type: :controller do
  before :each do
    WebMock.disable_net_connect!
    MetsPackage.sync
    @test_pdf = File.read("spec/fixtures/test-packages/GUB0100143/pdf/GUB0100143.pdf")
    @test_pdf_digest = Digest::SHA256.hexdigest(@test_pdf)
    @test_pdf_copyrighted = File.read("spec/fixtures/test-packages/GUB0109443/pdf/GUB0109443.pdf")
    @test_pdf_copyrighted_digest = Digest::SHA256.hexdigest(@test_pdf)
  end

  after :each do
    WebMock.allow_net_connect!
  end

  describe "get file" do
    it "should get file by id" do
      get :file, package_name: "GUB0100143", file_id: "pdfGUB0100143"
      expect(Digest::SHA256.hexdigest(response.body)).to eq(@test_pdf_digest)
      expect(response.status).to eq(200)
    end

    it "should give error for wrong package name" do
      get :file, package_name: "GUB0999143", file_id: "pdfGUB0100143"
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(404)
    end

    it "should give error for wrong file_id" do
      get :file, package_name: "GUB0100143", file_id: "pdfGUB010014999"
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(404)
    end

    it "should give error for wrong missing file" do
      get :file, package_name: "GUB0100143", file_id: "alto0235"
      expect(json['error']).to_not be_nil
      expect(response.status).to eq(404)
    end

    it "should give error if file is copyrighted and user is not authorized" do
      get :file, package_name: "GUB0109443", file_id: "pdfGUB0109443"
      expect(response.status).to eq(401)
    end

    it "should allow user access to copyrighted package if valid link is given" do
      expire_date = Time.now + (60*60*24) #Today plus one day
      link = Link.generate("GUB0109443", expire_date)
      link.save

      get :file, package_name: "GUB0109443", file_id: "pdfGUB0109443", link_hash: link.link_hash

      expect(Digest::SHA256.hexdigest(response.body)).to eq(@test_pdf_copyrighted_digest)
      expect(response.status).to eq(200)
    end
  end
end
