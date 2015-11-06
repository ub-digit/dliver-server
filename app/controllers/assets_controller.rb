class AssetsController < ApplicationController

  before_filter :validate_access
  before_filter :validate_files_access

  def file
    if @unlocked == false
      error_msg(ErrorCodes::AUTH_ERROR, "You don't have permission to download this file")
      render_json
      return
    end
    # Job PDF asset
    package = MetsPackage.find_by_name(params[:package_name])

    file_data = package.find_file_by_file_id(params[:file_id]) if package
    full_path = APP_CONFIG["store_path"] + "/" + package.name + "/" + file_data[:location] if file_data
    if !file_data
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find file with id: #{params[:file_id]}")
      render_json
    elsif !File.exist?(full_path)
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find file: #{file_data[:location]}")
      render_json
    else
      file = File.open(full_path)
      @response = {ok: "success"}
      send_data file.read, filename: file_data[:name], disposition: "inline"
    end
  end
end
