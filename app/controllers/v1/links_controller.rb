class V1::LinksController < V1::ApiController
  before_filter -> { validate_rights 'admin' }, only: [:create, :update, :destroy]
  before_filter -> { validate_rights 'admin' }, only: [:index]

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
end
