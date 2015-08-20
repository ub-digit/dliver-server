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

    describe "search_string" do
      it "should return correct search string" do
        search_string = @gubs_interface.search_string
        
        expect(search_string).to be_a String
        expect(search_string).to match(/Målningar av Eva Arosenius/)
        expect(search_string).to match(/Eva Arosenius/)
      end
    end

    describe "author" do
      it "should return correct author string" do
        author = @gubs_interface.author
        
        expect(author).to be_a String
        expect(author).to eq "Eva Arosenius (1906-2004)"
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

    describe "search_string" do
      it "should return correct search string" do
        search_string = @gubs_interface.search_string
        
        expect(search_string).to be_a String
        expect(search_string).to match(/Brev från Astrid Constantine-Torstensson till Nils Bonde Adler/)
        expect(search_string).to match(/Astrid Constantine-Torstensson/)
      end
    end

    describe "author" do
      it "should return correct author string" do
        author = @gubs_interface.author
        
        expect(author).to be_a String
        expect(author).to eq "Astrid Constantine-Torstensson (1935-)"
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
