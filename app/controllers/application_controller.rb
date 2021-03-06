require 'pp'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :setup

  # Setup global state for response
  def setup
    @response ||= {}
  end
  
  # Renders the response object as json with proper request status
  def render_json(status=200)
    # If successful, render given status
    if @response[:error].nil?
      render json: @response, status: status
    else
      # If not successful, render with status from ErrorCodes module
      render json: @response, status: ErrorCodes.const_get(@response[:error][:code])[:http_status]
    end
  end

  # Generates an error object from code, message and error list
  def error_msg(code=ErrorCodes::ERROR, msg="", error_list = nil)
    @response[:error] = {code: code[:code], msg: msg, errors: error_list}
  end

  private

  # checks if current user has the rights to execute given method
  def validate_rights(right_value)
    validate_access if !@current_user
    if !@current_user.has_right?(right_value)
      error_msg(ErrorCodes::PERMISSION_ERROR, "You don't have the necessary rights (#{right_value}) to perform this action")
      render_json
    end
  end

  # Sets user according to token or api_key, or guest if none is valid
  def validate_access
    if !validate_token && !validate_key
      @current_user = User.new(username: 'guest', name: 'Guest', role: "GUEST")
    end
  end

  # Validates token and sets user if token if valid
  def validate_token
    return if @current_user
    token = get_token
    token.force_encoding('utf-8') if token
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token)
      @current_user = token_object.user
      return true
    else
      return false
    end
  end

  # Validates given api_key against configurated key and sets user to api_key_user
  def validate_key
    return if @current_user
    api_key = params[:api_key]
    api_user = APP_CONFIG["api_key_users"].find{|x| !x.nil? && x["api_key"] == api_key}
    if api_user
      api_user = api_user.dup
      api_user.delete("api_key")
      @current_user = User.new(api_user)
      return true
    else
      return false
    end
  end

  # Returns mtoken from request headers or params[:token] if set
  def get_token
    if params.has_key?(:token) && params[:token] != ''
      return params[:token]
    end
    return nil if !request || !request.headers
    token_response = request.headers['Authorization']
    return nil if !token_response
    token_response[/^Token (.*)/,1]
  end

  def validate_files_access
    package = MetsPackage.find_by_name(params[:package_name])
    if !package
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find package with name: #{params[:package_name]}")
      render_json
      return
    end
    @unlocked = false

    if !package.copyrighted?
      @unlocked = true
      return
    else
      # Validate user rights
      if @current_user.has_right?('admin')
        @unlocked = true
        return
      end
      
      # Validate link_hash if it exists
      if params[:link_hash].present?
        link = Link.where(link_hash: params[:link_hash], package_name: package.name).first
        # Check if link exists
        if !link
          error_msg(ErrorCodes::OBJECT_ERROR, "Link does not exist for package #{package.name}")
          render_json
          return
        end
        #Check if link is still valid
        if link.expire_date < Time.now
          error_msg(ErrorCodes::AUTH_ERROR, "Link is expired since #{link.expire_date}")
          render_json
          return
        end

        @unlocked = true
        @unlocked_until_date = link.expire_date
        return true
      end
      return false
    end
  end
end
