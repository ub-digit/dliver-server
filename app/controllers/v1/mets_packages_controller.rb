class V1::MetsPackagesController < ApplicationController

  before_filter :validate_access
  before_filter :validate_files_access, only: [:show]

  def index
    packages = MetsPackage.all
    if params[:query]
      packages = packages.where("search_string LIKE ?", "%#{params[:query].norm}%")
    end

    render json: {mets_packages: packages}, status: 200
  end

  def show
    package = MetsPackage.find_by_name(params[:package_name])

    if package
      @response[:mets_package] = package.as_json
      
      if @unlocked #If package is unlocked via link_hash
        @response[:mets_package][:unlocked] = @unlocked
        @response[:mets_package][:unlocked_until_date] = @unlocked_until_date
      end

    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find package with name #{params[:package_name]}")
    end

    render_json
  end
end
