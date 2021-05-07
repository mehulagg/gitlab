# frozen_string_literal: true
module EE
  module AlertManagement
    module AlertsFinder
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      private

      # EE users can see alerts create by agent
      override :by_domain
      def by_domain(collection)
        unless project.feature_available?(:cilium_alerts) && params[:domain] == 'threat_monitoring'
          return super
        end

        collection.with_threat_monitoring_alerts
      end
    end
  end
end
