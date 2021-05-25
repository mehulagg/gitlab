# frozen_string_literal: true

module EE
  module BaseCountService
    extend ::Gitlab::Utils::Override

    # geo secondary cache should expire quicker than primary, otherwise various counts
    # could be incorrect for 2 weeks.
    override :cache_options
    def cache_options
      super.tap do |options|
        options[:expires_in] = 20.minutes if ::Gitlab::Geo.secondary?
      end
    end

    override :delete_cache
    def delete_cache
      super

      Geo::CacheInvalidationEventStore.new(cache_key).create! if ::Gitlab::Geo.primary?
    end
  end
end
