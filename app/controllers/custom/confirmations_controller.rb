class Custom::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  def show
    super do |resource|
      if resource.errors.empty?
        redirect_to("#{params[:redirect_url]}?account_confirmation_success=true", allow_other_host: true) and return
      else
        redirect_to("#{params[:redirect_url]}?account_confirmation_success=false", allow_other_host: true) and return
      end
    end
  end
end
