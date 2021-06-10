# frozen_string_literal: true

module EE
  module BaseCountService
    extend ::Gitlab::Utils::Override

    # When updating a cached count on a Geo primary, also invalidate the key on
    # Geo secondaries.
    override :update_cache_for_key
    def update_cache_for_key(key, &block)
      super.tap do
        ::Gitlab::Cache.delete_on_geo_secondaries(key)
      end
    end
  end
end
