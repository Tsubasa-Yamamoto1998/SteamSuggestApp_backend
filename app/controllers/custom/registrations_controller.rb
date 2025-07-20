class Custom::RegistrationsController < DeviseTokenAuth::RegistrationsController
  wrap_parameters format: []

  def create
    build_resource

    if @resource.save
      @resource.send_confirmation_instructions if @resource.respond_to?(:send_confirmation_instructions)
      render_create_success
    else
      render_create_error
    end

    unless @resource.valid?
      puts "Validation errors hash: #{@resource.errors.to_hash}"
      puts "Validation error details: #{@resource.errors.details}"
    end
  end

  protected

  def build_resource
    @resource = resource_class.new(sign_up_params)
  end

  def render_create_success
    render json: {
      status: "success",
      data: @resource.as_json(only: [ :id, :email, :username ])
    }, status: :ok
  end

  def render_create_error
    render json: {
      status: "error",
      errors: @resource.errors.full_messages
    }, status: :unprocessable_entity
  end

  private

  def sign_up_params
    params.permit(:username, :email, :password, :password_confirmation)
  end
end
