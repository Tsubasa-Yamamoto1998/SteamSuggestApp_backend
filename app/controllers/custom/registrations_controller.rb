class Custom::RegistrationsController < DeviseTokenAuth::RegistrationsController
  def create
    build_resource(sign_up_params)

    unless resource.save
      Rails.logger.debug resource.errors.full_messages
      render json: { status: "error", errors: resource.errors.full_messages }, status: 422
      return
    end

    yield resource if block_given?

    if resource.active_for_authentication?
      client_id = SecureRandom.uuid
      token = resource.create_token(client_id)
      resource.save!
      update_auth_header(resource)
      render_create_success
    else
      expire_data_after_sign_in!
      render_create_success
    end
  end

  private

  def sign_up_params
    params.permit(:username, :email, :password, :password_confirmation, :confirm_success_url)
  end
end
