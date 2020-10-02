# frozen_string_literal: true

module Types
  class ContainerRepositoryStatusEnum < BaseEnum
    graphql_name 'ContainerRepositoryStatus'
    description 'Status of a container repository'

    value 'DELETE_SCHEDULED', 'Deletion for this container repository has been scheduled.', value: :delete_scheduled
    value 'DELETE_FAILED', 'Deletion for this container repository has failed.', value: :delete_failed
  end
end
