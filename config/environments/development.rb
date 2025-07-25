require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.hosts << "localhost"

  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  config.cache_store = :mem_cache_store, "localhost", { namespace: "sg_app", compress: true }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # Set localhost to be used by links generated in mailer templates.
  # config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: "smtp.gmail.com",
  #   port: 587,
  #   domain: "gmail.com",
  #   user_name: "tsubasayamamoto1027@gmail.com",
  #   password: ENV["GMAIL_APP_PASSWORD"], # 環境変数からパスワードを取得
  #   authentication: "plain",
  #   enable_starttls_auto: true,
  #   openssl_verify_mode: "none" # 開発環境のみで使用。
  # }

  # .env.development を読み込む
  require "dotenv"
  Dotenv.load(".env.development")

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV["BREVO_SMTP_SERVER"],
    port: ENV["BREVO_SMTP_PORT"],
    domain: "localhost:5173", # フロントの開発用ドメインでOK
    user_name: ENV["BREVO_SMTP_USERNAME"],
    password: ENV["BREVO_SMTP_PASSWORD"],
    authentication: :login,
    enable_starttls_auto: true,
    openssl_verify_mode:  "none"
  }
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  config.force_ssl = false # ← 忘れずに明示的に

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!

  # デバッグのためにログレベルを設定
  config.log_level = :debug

  config.after_initialize do
    ActiveStorage::Current.url_options = {
      protocol: "http",
      host: "localhost",
      port: 3000
    }
  end

  Rails.application.routes.default_url_options[:host] = "http://localhost:3000"
end
