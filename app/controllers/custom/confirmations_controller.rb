class Custom::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  def show
    super do |resource|
      redirect_url = safe_redirect_url(params[:redirect_url], success: resource.errors.empty?)
      redirect_to(redirect_url, allow_other_host: true) and return
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
