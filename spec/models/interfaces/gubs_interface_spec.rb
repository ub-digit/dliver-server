# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe GubsInterface, type: :model do

  describe "document" do
    before :each do
      mets_package = create(:document_package)
      @document_mets_interface = mets_package.mets_object
      @gubs_interface = @document_mets_interface.wrapped_object
    end

    describe "id" do
      it "should return correct ID string" do
        id = @gubs_interface.id
        
        expect(id).to be_a String
        expect(id).to eq "2208"
      end
    end

    describe "title" do
      it "should return correct title string" do
        title = @gubs_interface.title
        
        expect(title).to be_a String
        expect(title).to eq "Målningar av Eva Arosenius"
      end
    end

    describe "sub_title" do
      it "should return correct sub title string" do
        sub_title = @gubs_interface.sub_title
        
        expect(sub_title).to be_a String
        expect(sub_title).to eq ""
      end
    end

    describe "language" do
      it "should return correct language string" do
        language = @gubs_interface.language
        
        expect(language).to be_a String
        expect(language).to eq "swe"
      end
    end

    describe "type_of_record" do
      it "should return correct type_of_record string" do
        type_of_record = @gubs_interface.type_of_record
        
        expect(type_of_record).to be_a Array
        expect(type_of_record).to include("manuscript")
        expect(type_of_record).to include("document")
      end
    end

    describe "search_string" do
      it "should return correct search string" do
        search_string = @gubs_interface.search_string
        
        expect(search_string).to be_a String
        expect(search_string).to match(/malningar av eva arosenius/)
        expect(search_string).to match(/eva arosenius/)
      end
    end

    describe "authors" do
      it "should return correct author string" do
        authors = @gubs_interface.authors
        
        expect(authors).to be_a String
        expect(authors).to eq "Eva Arosenius (1906-2004)"
      end
    end

    describe "source" do
      it "should return correct source string" do
        source = @gubs_interface.source
        
        expect(source).to be_a String
        expect(source).to eq "document"
      end
    end

    describe "year" do
      it "should return correct year" do
        year = @gubs_interface.year
        
        expect(year).to be_a String
        expect(year).to eq "1919"
      end
    end

  end

  describe "letter" do
    before :each do
      mets_package = create(:letter_package)
      @letter_mets_interface = mets_package.mets_object
      @gubs_interface = @letter_mets_interface.wrapped_object
    end

    describe "id" do
      it "should return correct ID string" do
        id = @gubs_interface.id
        
        expect(id).to be_a String
        expect(id).to eq "27656"
      end
    end

    describe "title" do
      it "should return correct title string" do
        title = @gubs_interface.title
        
        expect(title).to be_a String
        expect(title).to eq "Brev från Astrid Constantine-Torstensson till Nils Bonde Adler"
      end
    end

    describe "sub_title" do
      it "should return correct sub title string" do
        sub_title = @gubs_interface.sub_title
        
        expect(sub_title).to be_a String
        expect(sub_title).to eq ""
      end
    end

    describe "language" do
      it "should return correct language string" do
        language = @gubs_interface.language
        
        expect(language).to be_a String
        expect(language).to eq "swe"
      end
    end

    describe "type_of_record" do
      it "should return correct type_of_record string" do
        type_of_record = @gubs_interface.type_of_record
        
        expect(type_of_record).to be_a Array
        expect(type_of_record).to include("manuscript")
        expect(type_of_record).to include("letter")
      end
    end

    describe "search_string" do
      it "should return correct search string" do
        search_string = @gubs_interface.search_string
        
        expect(search_string).to be_a String
        expect(search_string).to match(/brev fran astrid constantine-torstensson till nils bonde adler/)
        expect(search_string).to match(/astrid constantine-torstensson/)
      end
    end

    describe "authors" do
      it "should return correct author string" do
        authors = @gubs_interface.authors
        
        expect(authors).to be_a String
        expect(authors).to eq "Astrid Constantine-Torstensson (1935-)"
      end
    end

    describe "source" do
      it "should return correct source string" do
        source = @gubs_interface.source
        
        expect(source).to be_a String
        expect(source).to eq "letter"
      end
    end

    describe "year" do
      it "should return correct year" do
        year = @gubs_interface.year
        
        expect(year).to be_a String
        expect(year).to eq "-"
      end
    end

  end
end
