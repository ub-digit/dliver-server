require 'rails_helper'

RSpec.describe MetsPackage, type: :model do
  before :each do
    WebMock.disable_net_connect!
  end

  after :each do
    WebMock.allow_net_connect!
  end

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
      expect(@mets_package.author).to eq "Nils Linnermark (1908-); Second Name (1999-)"
    end

    it "should have year" do
      expect(@mets_package.year).to eq("1960")
    end

    it "should have type_of_record" do
      expect(@mets_package.type_of_record).to be_a(Array)
      expect(@mets_package.type_of_record).to include("theses")
    end

    it "should have search_string" do
      expect(@mets_package.search_string).to match(/podsol och brunjord/)
      expect(@mets_package.search_string).to match(/en studie/)
      expect(@mets_package.search_string).to match(/nils/)
    end

    it "should have catalog_id" do
      metadata = JSON.parse(@mets_package.metadata)
      expect(metadata["catalog_id"]).to eq("663299")
    end

    it "should have source" do
      metadata = JSON.parse(@mets_package.metadata)
      expect(metadata["source"]).to eq("libris")
    end

    it "should have language" do
      metadata = JSON.parse(@mets_package.metadata)
      expect(metadata["language"]).to eq("swe")
    end

  end

  describe "sync" do
    before :each do
      @package_count = 14 # Number of packages in folder fixtures/test-packages
    end
    context "no data in database" do
      it "should read all files in configured path structure and import them" do
        expect(MetsPackage.count).to eq(0)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(@package_count)
      end
    end

    context "one item has been removed in filesystem" do
      before :each do 
        MetsPackage.sync
        create(:libris_package)
      end

      it "should purge the removed package from database" do
        expect(MetsPackage.count).to eq(@package_count+1)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(@package_count)
      end
    end

    context "one item in filesystem is not included in database" do
      before :each do 
        MetsPackage.sync
        MetsPackage.first.destroy
      end

      it "should purge the removed package from database" do
        expect(MetsPackage.count).to eq(@package_count-1)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(@package_count)
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
        expect(MetsPackage.count).to eq(@package_count)
        MetsPackage.sync
        expect(MetsPackage.count).to eq(@package_count)
        changed = MetsPackage.find_by_xmlhash("something_else")
        expect(changed).to be_nil
      end
    end
    
    context "one item is re-synchronized" do
      it "should keep other items in database" do
        MetsPackage.sync
        package = MetsPackage.first

        MetsPackage.sync(package_id: package.name)

        expect(MetsPackage.count).to eq @package_count
      end
    end
  end

  describe "xml_file" do
    context "for an existing mets file" do
      it "should return a path to the source xml file" do
        package = create(:mets_package, name: "TestPackage")
        
        xml_path = package.xml_file
        
        expect(xml_path).to eq "#{APP_CONFIG['store_path']}/TestPackage/TestPackage_mets.xml"
      end
    end
  end

  describe "archive_xml_file" do
    context "for an existing package" do
      it "should move package xml file to history folder" do
        MetsPackage.sync
        package = MetsPackage.first
        
        package.archive_xml_file

        expect(Pathname.new(package.xml_file).exist?).to be_falsey
        expect(Pathname.new(package.archive_path).children.first).to_not be nil
      end
    end
  end

end
