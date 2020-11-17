# frozen_string_literal: true

module EE
  module SearchController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      # track unique users of advanced global search
      track_redis_hll_event :show, name: 'i_search_advanced', feature: :search_track_unique_users, feature_default_enabled: true,
        if: :track_search_advanced?

      # track unique paid users (users who already use elasticsearch and users who could use it if they enable elasticsearch integration)
      # for gitlab.com we check if the search uses elasticsearch
      # for self-managed we check if the licensed feature available
      track_redis_hll_event :show, name: 'i_search_paid', feature: :search_track_unique_users, feature_default_enabled: true,
        if: :track_search_paid?
    end

    private

    override :default_sort
    def default_sort
      if search_service.use_elasticsearch?
        'relevant'
      else
        super
      end
    end

    def track_search_advanced?
      search_service.use_elasticsearch?
    end

    def track_search_paid?
      if ::Gitlab.com?
        search_service.use_elasticsearch?
      else
        License.feature_available?(:elastic_search)
      end
    end
  end
end
