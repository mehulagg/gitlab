# frozen_string_literal: true

module IncidentManagement
  module IncidentSla
    class << self
      def available_for?(project)
        ::Feature.enabled?(:incident_sla_dev, project) && project.feature_available?(:incident_sla)
      end
    end
  end
end
