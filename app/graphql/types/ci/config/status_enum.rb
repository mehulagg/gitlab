# frozen_string_literal: true

module Types
  module Ci
    module Config
      class StatusEnum < BaseEnum
        graphql_name 'CiConfigStatusEnum'
        description 'Values for YAML processor result'

        value 'valid', 'Valid gitlab-ci.yml', value: 'valid'
        value 'INVALID', 'Invalid gitlab-ci.yml'
      end
    end
  end
end
