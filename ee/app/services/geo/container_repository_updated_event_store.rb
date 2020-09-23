# frozen_string_literal: true

module Geo
  class ContainerRepositoryUpdatedEventStore < EventStore
    self.event_type = :container_repository_updated_event

    attr_reader :repository

    def initialize(repository)
      @repository = repository
    end

    private

    def build_event
      Geo::ContainerRepositoryUpdatedEvent.new(
        container_repository: repository
      )
    end

    # This is called by LogHelpers to build json log with context info
    #
    # @see ::Gitlab::Geo::LogHelpers
    def extra_log_data
      {
        container_repository_id: repository.try(:id)
      }.compact
    end
  end
end
