# frozen_string_literal: true

module EE
  module Admin
    module DevOpsReportController
      def show_adoption?
        feature_already_in_use = ::Analytics::DevopsAdoption::Segment.any?

        ::Feature.enabled?(:devops_adoption_feature, default_enabled: feature_already_in_use) &&
          ::License.feature_available?(:devops_adoption)
      end
    end
  end
end
