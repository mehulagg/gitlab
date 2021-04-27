# frozen_string_literal: true

module EE
  module AlertManagement
    module AlertPresenter
      extend ActiveSupport::Concern

      def details_url
        return threat_monitoring_alert_project_threat_monitoring_url(project, alert.iid) if alert.threat_monitoring?

        super
      end
    end
  end
end
