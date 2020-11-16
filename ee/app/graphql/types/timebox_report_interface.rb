# frozen_string_literal: true

module Types
  module TimeboxReportInterface
    include BaseInterface

    field :report, Types::TimeboxReportType, null: true,
          resolver: ::Resolvers::TimeboxReportResolver,
          description: 'Historically accurate report about the timebox',
          complexity: 175
  end
end
