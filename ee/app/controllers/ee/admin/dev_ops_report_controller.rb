# frozen_string_literal: true

module EE
  module Admin
    module DevOpsReportController
      extend ActiveSupport::Concern
      prepended do
        track_redis_hll_event :show, name: 'i_analytics_dev_ops_adoption', if: -> { params[:tab] != 'devops-score' }
      end

      def should_track_devops_score?
        params[:tab] == 'devops-score'
      end

      def show_adoption?
        feature_already_in_use = ::Analytics::DevopsAdoption::EnabledNamespace.any?

        ::License.feature_available?(:devops_adoption) &&
          (feature_already_in_use || ::Feature.enabled?(:devops_adoption_feature, default_enabled: :yaml))
      end
    end
  end
end
