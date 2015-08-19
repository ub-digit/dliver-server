require 'rails_helper'

RSpec.describe V1::MetsPackagesController, type: :controller do

  describe "index" do
    context "for existing mets packages" do
      it "should return a list of mets packages" do
        create_list(:mets_package, 5)

        get :index

        expect(json['mets_packages'].count).to eq 5
      end
    end

    context "searching for mets packages" do
      it "should return a selection of mets packages" do
        create(:mets_package_empty, search_string: "en vanlig text")
        create(:mets_package_empty, search_string: "en annan text")
        create(:mets_package_empty, search_string: "mer vanlig")

        get :index, query: "text"
        expect(json['mets_packages'].count).to eq 2

        get :index, query: "annan"
        expect(json['mets_packages'].count).to eq 1

        get :index, query: "vanlig"
        expect(json['mets_packages'].count).to eq 2
      end
    end
  end
end
