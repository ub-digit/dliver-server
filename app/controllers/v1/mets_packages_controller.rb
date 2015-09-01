class V1::MetsPackagesController < ApplicationController

  before_filter :validate_access
  before_filter :validate_files_access, only: [:show]

  def index
    packages = MetsPackage.all
    if params[:query]
      packages = packages.where("search_string LIKE ?", "%#{params[:query].norm}%").limit(100)
    end

    render json: {mets_packages: packages}, status: 200
  end

  def show
    package = MetsPackage.find_by_name(params[:package_name])

    if package
      @response[:mets_package] = package.as_json
      
      if @unlocked 
        @response[:mets_package][:unlocked] = @unlocked
        @response[:mets_package][:unlocked_until_date] = @unlocked_until_date
      end

      # If user is admin, include links
      if @current_user.has_right?('admin')
        @response[:mets_package][:links] = Link.where(package_name: package.name)
      end

    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find package with name #{params[:package_name]}")
    end

    render_json
  end
end
