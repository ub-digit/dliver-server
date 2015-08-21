class V1::MetsPackagesController < ApplicationController

  def index
    packages = MetsPackage.all
    if params[:query]
      packages = packages.where("search_string LIKE ?", "%#{params[:query].norm}%")
    end

    render json: {mets_packages: packages}, status: 200
  end

  def show
    package = MetsPackage.find_by_name(params[:name])

    if package
      @response[:mets_package] = package
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find package with name #{params[:name]}")
    end

    render_json
  end
end
