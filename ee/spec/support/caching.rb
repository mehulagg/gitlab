# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :use_sql_query_cache_for_tracking_db) do |example|
    Geo::TrackingBase.cache do
      example.run
    end
  end
end
