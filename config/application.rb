require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TAKBackEnd
  class Application < Rails::Application
    config.time_zone = "Asia/Karachi"
    config.active_record.default_timezone = :local # Or :utc
    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.eager_load_paths << "#{Rails.root}/lib/concerns"
    config.active_job.queue_adapter = :delayed_job

    require 'rack/cors'
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exist?(env_file)
    end
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post options delete put patch]
      end
    end
  end
end
