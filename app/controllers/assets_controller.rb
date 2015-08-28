class AssetsController < ApplicationController

  before_filter :validate_access
  def file
    # Job PDF asset
    package = MetsPackage.find_by_name(params[:package_name])
    # Make sure user has proper rights to download file
    if package.copyrighted?
      if @current_user.has_right?('admin')
        # Do nothing
      else
        error_msg(ErrorCodes::AUTH_ERROR, "You do not have the proper rights to download this file")
        render_json
        return
      end
    end

    file_data = package.find_file_by_file_id(params[:file_id]) if package
    full_path = APP_CONFIG["store_path"] + "/" + package.name + "/" + file_data[:location] if file_data
    if !package
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find package with name: #{params[:package_name]}")
      render_json
    elsif !file_data
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find file with id: #{params[:file_id]}")
      render_json
    elsif !File.exist?(full_path)
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find file: #{file_data[:location]}")
      render_json
    else
      file = File.open(full_path)
      @response = {ok: "success"}
      send_data file.read, filename: params[:file_name], disposition: "inline"
    end
  end
end
