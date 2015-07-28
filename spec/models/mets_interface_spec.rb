require 'rails_helper'

RSpec.describe MetsInterface, type: :model do

  before :each do
     mets_package = create(:mets_package)
     @libris_mets_interface = mets_package.mets_object
  end

  describe "id" do
    context "For libris xml" do
      it "should return correct ID string" do
        id = @libris_mets_interface.id

        expect(id).to be_a String
        expect(id).to eq "GUB0102377"
      end
    end
  end

  describe "create_date" do
    context "For librs xml" do
      it "should return a DateTime object" do
        create_date = @libris_mets_interface.create_date
        mock_obj = DateTime.iso8601('2015-05-22T12:01:44')

        expect(create_date).to be_a DateTime
        expect(create_date).to eq mock_obj
      end
    end
  end

  describe "last_modification_date" do
    context "For libris xml" do
      it "should return a DateTime object" do
        last_modification_date = @libris_mets_interface.last_modification_date
        mock_obj = DateTime.iso8601('2015-07-24T11:14:09')

        expect(last_modification_date).to be_a DateTime
        expect(last_modification_date).to eq mock_obj
      end
    end
  end

  describe "agents" do
    context "for libris xml with a CREATOR and ARCHIVIST agent" do
      it "should return an array of hash objects" do
        agents = @libris_mets_interface.agents

        expect(agents).to be_an Array
        expect(agents.first).to be_a Hash
      end
    end
  end

  describe "creator_agent" do
    context "for libris xml with CREATOR" do
      it "should return a hash object" do
        creator_agent = @libris_mets_interface.creator_agent

        expect(creator_agent).to be_a Hash
        expect(creator_agent[:name]).to eq "GUB, Göteborgs universitetsbibliotek, Digitala tjänster"
      end
    end
  end

  describe "archivist_agent" do
    context "for libris xml with ARCHIVIST" do
      it "should return a hash object" do
        archivist_agent = @libris_mets_interface.archivist_agent

        expect(archivist_agent).to be_a Hash
        expect(archivist_agent[:name]).to eq "UUB, Uppsala universitetsbibliotek"
      end
    end
  end

  describe "copyright_status" do
    context "for libris xml with copyright" do
      it "should return copyrighted string" do
        copyright_status = @libris_mets_interface.copyright_status

        expect(copyright_status).to eq "copyrighted"
      end
    end
  end

  describe "file_groups" do
    context "for libris xml with files" do
      it "should return an array of groups" do
        file_groups = @libris_mets_interface.file_groups

        expect(file_groups).to be_an Array
        expect(file_groups.count).to eq 4
      end
    end
  end
end
