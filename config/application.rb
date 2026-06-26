require_relative "boot"

require "rails/all"

# Ruby's URI parser doesn't know the oracle-enhanced scheme; without
# registration it treats user:pass@host as a "registry" part and raises
# URI::InvalidURIError when DATABASE_URL is set. Register it here,
# before any Railtie initializer processes DATABASE_URL.
require "uri"
module URI
  class OracleEnhanced < Generic
    DEFAULT_PORT = 1521
  end
end
URI.register_scheme("ORACLE-ENHANCED", URI::OracleEnhanced)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups, :oracle)

module RailsAzurePoc
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
