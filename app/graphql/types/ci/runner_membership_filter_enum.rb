# frozen_string_literal: true

module Types
  module Ci
    class RunnerMembershipFilterEnum < BaseEnum
      graphql_name 'RunnerMembershipFilter'
      description 'Values for filtering runners in namespaces.'

      value 'ALL',
            description: "Include all runners that have either a direct or indirect relationship.",
            value: :all

      value 'DIRECT',
            description: "Include runners that have a direct relationship.",
            value: :direct

      value 'DESCENDENTS',
            description: "Include runners that have either a direct relationship or a relationship with descendants.",
            value: :descendents
    end
  end
end
