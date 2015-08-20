require 'rails_helper'

RSpec.describe MetsPackage, type: :model do
  describe "search_string" do
    it {should validate_presence_of(:search_string)}
  end

  describe "create" do
    before :each do
      @mets_package = create(:libris_package)
    end
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

  describe "sync" do
    context "no data in database" do
      it "should read all files in configured path structure and import them" do
        expect(MetsPackage.count).to eq(0)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(12)
      end
    end

    context "one item has been removed in filesystem" do
      before :each do 
        MetsPackage.sync
        create(:libris_package)
      end

      it "should purge the removed package from database" do
        expect(MetsPackage.count).to eq(13)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(12)
      end
    end

    context "one item in filesystem is not included in database" do
      before :each do 
        MetsPackage.sync
        MetsPackage.first.destroy
      end

      it "should purge the removed package from database" do
        expect(MetsPackage.count).to eq(11)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(12)
      end
    end

    context "one item in filesystem is updated" do
      before :each do 
        MetsPackage.sync
        MetsPackage.first.update_attribute(:xmlhash, "something_else")
      end

      it "should purge the removed package from database" do
        changed = MetsPackage.find_by_xmlhash("something_else")
        expect(changed).to_not be_nil
        expect(MetsPackage.count).to eq(12)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(12)
        changed = MetsPackage.find_by_xmlhash("something_else")
        expect(changed).to be_nil
      end
    end
  end
end
