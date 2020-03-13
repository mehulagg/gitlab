# frozen_string_literal: true

def enable_oj?
  return false unless Feature::FlipperFeature.table_exists?

  Feature.enabled?(:multijson_oj, default_enabled: true)
rescue
  false
end

if enable_oj?
  MultiJson.use(:oj)
  Oj.default_options = { mode: :rails }

  # This is equivalent to Oj.optimize_rails()
  # but does not replace the default JSON class
  Oj::Rails.set_encoder()
  Oj::Rails.set_decoder()
  Oj::Rails.optimize()
else
  MultiJson.use(:ok_json)
end
