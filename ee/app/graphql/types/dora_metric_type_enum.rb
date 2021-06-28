# frozen_string_literal: true

module Types
  class DoraMetricTypeEnum < BaseEnum
    graphql_name 'DoraMetricType'
    description 'All supported DORA metric types.'

    value 'DEPLOYMENT_FREQUENCY', description: 'Deployment frequency.', value: 'deployment_frequency'
    value 'LEAD_TIME_FOR_CHANGES', description: 'Lead time for changes.', value: 'lead_time_for_changes'
  end
end
