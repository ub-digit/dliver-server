require 'rails_helper'

RSpec.describe V1::MetsPackagesController, type: :controller do

  describe "index" do
    before :each do
      WebMock.disable_net_connect!

      resultsnippet1 = File.read("spec/fixtures/solr_response_1_item.rb.txt")
      resultsnippet2 = File.read("spec/fixtures/solr_response_2_items.rb.txt")
      resultsnippet5 = File.read("spec/fixtures/solr_response_5_items.rb.txt")

      stub_request(:get, "http://localhost:8983/solr/dliver/select?defType=edismax&facet=true&facet.field=language&facet.mincount=1&fl=score,*&hl=true&hl.fl=*&hl.snippets=10&q=text&qf=title%5E100%20author%5E10%20alt_title%20sub_title%20alt_sub_title&wt=ruby").
        to_return(:status => 200, :body => resultsnippet2, :headers => {})


      stub_request(:get, "http://localhost:8983/solr/dliver/select?defType=edismax&facet=true&facet.field=language&facet.mincount=1&fl=score,*&hl=true&hl.fl=*&hl.snippets=10&q=annan&qf=title%5E100%20author%5E10%20alt_title%20sub_title%20alt_sub_title&wt=ruby").
        to_return(:status => 200, :body => resultsnippet1, :headers => {})

      stub_request(:get, "http://localhost:8983/solr/dliver/select?defType=edismax&facet=true&facet.field=language&facet.mincount=1&fl=score,*&hl=true&hl.fl=*&hl.snippets=10&q=vanlig&qf=title%5E100%20author%5E10%20alt_title%20sub_title%20alt_sub_title&wt=ruby").
        to_return(:status => 200, :body => resultsnippet2, :headers => {})

      stub_request(:get, "http://localhost:8983/solr/dliver/select?defType=edismax&facet=true&facet.field=language&facet.mincount=1&fl=score,*&hl=true&hl.fl=*&hl.snippets=10&qf=title%5E100%20author%5E10%20alt_title%20sub_title%20alt_sub_title&wt=ruby").
        to_return(:status => 200, :body => resultsnippet5, :headers => {})
    end

    after :each do
      WebMock.allow_net_connect!
    end

    context "for existing mets packages" do
      it "should return a list of mets packages" do
        create_list(:mets_package, 5)

#j        get :index

#j        expect(json['mets_packages'].count).to eq 5
      end
    end

    context "searching for mets packages" do
      it "should return a selection of mets packages" do
        create(:mets_package_empty, search_string: "en vanlig text")
        create(:mets_package_empty, search_string: "en annan text")
        create(:mets_package_empty, search_string: "mer vanlig")

 #       get :index, query: "text"
 #       expect(json['mets_packages'].count).to eq 2

 #       get :index, query: "annan"
 #       expect(json['mets_packages'].count).to eq 1

 #       get :index, query: "vanlig"
 #       expect(json['mets_packages'].count).to eq 2
      end

      it "should return a selection of mets packages with upper case characters present" do
        create(:mets_package_empty, search_string: "en Vanlig Text")
        create(:mets_package_empty, search_string: "en annan Text")
        create(:mets_package_empty, search_string: "mer vanlig")

      #  get :index, query: "text"
 #       expect(json['mets_packages'].count).to eq 2

   #     get :index, query: "annan"
 #       expect(json['mets_packages'].count).to eq 1

   #     get :index, query: "vanlig"
 #       expect(json['mets_packages'].count).to eq 2
      end
    end
  end

  describe "show" do
    context "specialised package" do
      before :each do
        MetsPackage.sync
        @libris_package = MetsPackage.find_by_name("GUB0101403")
      end

      it "should return publisher" do
        get :show, package_name: @libris_package.name
        expect(json['mets_package']['publisher']).to be_present
      end
    end
    context "generic package" do
      before :each do
        @libris_package = create(:libris_package)
      end

      it "should return existing item" do
        get :show, package_name: @libris_package.name
        expect(json['mets_package']).to_not be_nil
        expect(response.status).to eq(200)
      end

      it "should return page_count" do
        get :show, package_name: @libris_package.name
        expect(json['mets_package']['page_count']).to eq(88)
        expect(response.status).to eq(200)
      end

      it "should return language" do
        get :show, package_name: @libris_package.name
        expect(json['mets_package']['language']).to eq("swe")
        expect(response.status).to eq(200)
      end

      it "should return 404 on non-existing item" do
        get :show, package_name: "Does not exist"
        expect(json['mets_package']).to be_nil
        expect(json['error']).to_not be_nil
        expect(response.status).to eq(404)
      end

      it "should not return mets xml" do
        get :show, package_name: @libris_package.name
        expect(json['mets_package']['xml']).to be_nil
      end

      it "should not return metadata field" do
        get :show, package_name: @libris_package.name
        expect(json['mets_package']['metadata']).to be_nil
      end
    end
    context "copyrighted package" do
      before :each do
        MetsPackage.sync
        @copyrighted_package = MetsPackage.find_by_name("GUB0109443")
      end
      it "should have unlocked flag with link_hash" do
        expire_date = Time.now + (60*60*24) #Today plus one day
        link = Link.generate("GUB0109443", expire_date)
        link.save
        get :show, package_name: @copyrighted_package.name, link_hash: link.link_hash
      end

      it "should contain unlocked flag with link_hash" do
        get :show, package_name: @copyrighted_package.name
      end
    end
  end
end
