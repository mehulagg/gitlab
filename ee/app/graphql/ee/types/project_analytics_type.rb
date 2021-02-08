module EE
  module Types
    module ProjectAnalyticsType
      extend ActiveSupport::Concern

      prepended do
        field :lead_time, [::Types::Ci::AnalyticsDataPointType], null: true,
          description: 'Pipeline analytics.',
          resolver: ::Resolvers::Ci::LeadTimeResolver
      end
    end
  end
end
