require 'rails_helper'

RSpec.describe MetsPackage, type: :model do
  before :each do
    @mets_package = create(:mets_package)
  end
  describe "search_string" do
    it {should validate_presence_of(:search_string)}
  end

  describe "create" do
    it "should have title" do
      expect(@mets_package.title).to eq("Podsol och brunjord")
    end

    it "should have sub_title" do
      expect(@mets_package.sub_title).to match(/en studie av vegetation/)
    end

    it "should have author" do
      expect(@mets_package.author).to eq("Nils Linnermark (1908-)")
    end

    it "should have year" do
      expect(@mets_package.year).to eq("1960")
    end

    it "should have search_string" do
      expect(@mets_package.search_string).to match(/Podsol och brunjord/)
      expect(@mets_package.search_string).to match(/en studie/)
      expect(@mets_package.search_string).to match(/Nils/)
    end

    it "should have catalog_id" do
      metadata = JSON.parse(@mets_package.metadata)
      expect(metadata["catalog_id"]).to eq("663299")
    end

    it "should have source" do
      metadata = JSON.parse(@mets_package.metadata)
      expect(metadata["source"]).to eq("libris")
    end

  end
end
