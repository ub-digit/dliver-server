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
  end
end
