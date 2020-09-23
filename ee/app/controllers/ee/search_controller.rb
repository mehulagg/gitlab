# frozen_string_literal: true

module EE
  module SearchController
    extend ActiveSupport::Concern

    prepended do
      before_action :track_advanced_search, only: :show, if: -> { ::Feature.enabled?(:search_track_unique_users, default_enabled: true) && request.format.html? && request.headers['DNT'] != '1' }
    end

    private

    def track_advanced_search
      # track unique users of advanced global search
      track_unique_redis_hll_event('i_search_advanced', :search_track_unique_users, true) if search_service.use_elasticsearch?

      # track unique paid users (users who already use elasticsearch and users who could use it if they enable elasticsearch integration)
      # for gitlab.com we check if the search uses elasticsearch
      # for self-managed we check if the licensed feature available
      track_unique_redis_hll_event('i_search_paid', :search_track_unique_users, true) if (::Gitlab.com? && search_service.use_elasticsearch?) || (!::Gitlab.com? && License.feature_available?(:elastic_search))
    end
  end
end
