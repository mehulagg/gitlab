# frozen_string_literal: true

module Types
  module Geo
    class RegistryStateEnum < BaseEnum
      graphql_name 'RegistryState'
      description 'State of a Geo registry'

      value 'PENDING', value: :pending, description: 'Registry waiting to be synced.'
      value 'STARTED', value: :started, description: 'Registry currently syncing.'
      value 'SYNCED', value: :synced, description: 'Registry that is synced.'
      value 'FAILED', value: :failed, description: 'Registry that failed to sync.'
    end
  end
end
