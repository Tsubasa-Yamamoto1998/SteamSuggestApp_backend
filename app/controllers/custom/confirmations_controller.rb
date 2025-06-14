class Custom::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  def show
    super do |resource|
      if resource.errors.empty?
        redirect_to(safe_redirect_url(params[:redirect_url], success: true)) and return
      else
        redirect_to(safe_redirect_url(params[:redirect_url], success: false)) and return
      end
    end
  end

  private

  def safe_redirect_url(base_url, success:)
    return root_path if base_url.blank?

    uri = URI.parse(base_url)
    query = { account_confirmation_success: success }.to_query
    uri.query = [ uri.query, query ].compact.join("&")
    uri.to_s
  rescue URI::InvalidURIError
    root_path
  end
end
