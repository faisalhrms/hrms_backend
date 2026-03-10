require "uri"

APP_HOST = ENV["APP_HOST"].presence || (Rails.env.production? ? "https://be.inferifi.com" : "http://127.0.0.1:3000")
uri = URI.parse(APP_HOST)

Rails.application.routes.default_url_options = { host: uri.host, protocol: uri.scheme }
Rails.application.config.action_controller.default_url_options = { host: uri.host, protocol: uri.scheme }
Rails.application.config.action_mailer.default_url_options = { host: uri.host, protocol: uri.scheme }
Rails.application.config.action_mailer.asset_host = APP_HOST

Paperclip.interpolates :app_host do |_att, _style| APP_HOST end

Paperclip::Attachment.default_options.update(
  url: ":app_host/system/:class/:attachment/:id/:style/:filename",
  path: ":rails_root/public/system/:class/:attachment/:id/:style/:filename",
  default_url: ":app_host/system/profile-placeholder.jpg",
  escape_url: false
)


