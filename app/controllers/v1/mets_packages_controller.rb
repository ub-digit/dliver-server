class V1::MetsPackagesController < ApplicationController

  def index
    packages = MetsPackage.all
    if params[:query]
      packages = packages.where("search_string LIKE ?", "%#{params[:query].norm}%")
    end

    render json: {mets_packages: packages}, status: 200
  end
end
