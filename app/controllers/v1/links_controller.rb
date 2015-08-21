class V1::LinksController < V1::ApiController
  before_filter -> { validate_rights 'admin' }, only: [:create, :update, :destroy]
  before_filter -> { validate_rights 'admin' }, only: [:index]

  def index
    @response[:links] = Link.where(package_name: params[:package_name])
    render_json
  end

  def show
    link = Link.find_by_link_hash(params[:link_hash])

    if link && link.is_valid?
      @response[:link] = link
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find link with hash #{params[:link_hash]}")
    end

    render_json
  end

  def create
    link = Link.generate(params[:link][:package_name], params[:link][:expire_date])
    if !link.save
      error_msg(ErrorCodes::VALIDATION_ERROR, "Could not create link", link.errors)
      render_json
    else
      @response[:link] = link
      render_json(201)
    end
  end

  def destroy
    link = Link.find_by_link_hash(params[:link_hash])

    if link && link.delete
      @response[:link] = link
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not delete link with hash #{params[:link_hash]}")
    end

    render_json
  end
end
