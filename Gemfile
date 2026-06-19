source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
# Requires Oracle Instant Client at install time.
# Scan/lint CI jobs skip this group via BUNDLE_WITHOUT=oracle.
group :oracle do
  gem "activerecord-oracle_enhanced-adapter"
  gem "ruby-oci8"
end
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
