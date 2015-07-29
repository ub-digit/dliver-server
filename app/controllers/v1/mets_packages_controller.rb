class V1::MetsPackagesController < ApplicationController

  def index
    render json: {mets_packages: MetsPackage.all}, status: 200
  end
end
