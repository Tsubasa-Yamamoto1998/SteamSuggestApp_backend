class Custom::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  def show
    resource = resource_class.confirm_by_token(params[:confirmation_token])

    # フラグの付与と保存（オプション）
    yield resource if block_given?

    redirect_url = safe_redirect_url(params[:redirect_url], success: resource.errors.empty?)
    redirect_to redirect_url, allow_other_host: true
  end

  private

  def safe_redirect_url(base_url, success:)
    return "/" if base_url.blank?

    begin
      uri = URI.parse(base_url)

      # 明示的に http/https で始まり、host が存在するもののみ許可
      unless uri.scheme.in?(%w[http https]) && uri.host.present?
        return "/"
      end

      query = { account_confirmation_success: success }.to_query
      uri.query = [ uri.query, query ].compact.join("&")
      uri.to_s
    rescue URI::InvalidURIError
      "/"
    end
  end
end
