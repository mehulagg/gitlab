# frozen_string_literal: true

def enable_oj?
  return true unless Feature::FlipperFeature.table_exists?

  Feature.enabled?(:multijson_oj, default_enabled: true)
end

if enable_oj?
  MultiJson.use(:oj)
  Oj.default_options = { mode: :rails }
  Oj.optimize_rails
else
  MultiJson.use(:ok_json)
end
