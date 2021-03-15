# frozen_string_literal: true

require Rails.root.join("spec/support/helpers/stub_requests.rb")

Dir[Rails.root.join("ee/spec/support/helpers/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("ee/spec/support/shared_contexts/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("ee/spec/support/shared_examples/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("ee/spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.include EE::LicenseHelpers

  config.define_derived_metadata(file_path: %r{ee/spec/}) do |metadata|
    location = metadata[:location]

    metadata[:geo] = metadata.fetch(:geo, true) if location =~ %r{[/_]geo[/_]}
  end

  config.before(:all) do
    License.destroy_all # rubocop: disable Cop/DestroyAll
    TestLicense.init
  end

  config.before do |example|
    if example.metadata.fetch(:stub_feature_flags, true)
      # This feature flag is by default disabled and used in a DEFCON mode
      stub_feature_flags(ci_queueing_defcon_disable_quota: false)
    end
  end

  config.around(:each, :geo_tracking_db) do |example|
    example.run if Gitlab::Geo.geo_database_configured?
  end
end
