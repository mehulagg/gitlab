# frozen_string_literal: true

module ResourceEvents
  class ChangeIterationService < ::ResourceEvents::BaseChangeTimeboxService
    attr_reader :iteration, :old_iteration_id

    def initialize(resource, user, created_at: Time.current, old_iteration_id:)
      super(resource, user, created_at: created_at)

      @iteration = resource&.iteration
      @old_iteration_id = old_iteration_id
    end

    private

    def create_event
      ResourceIterationEvent.create(build_resource_args)
    end

    def build_resource_args
      action = iteration.blank? ? :remove : :add

      super.merge({
                    action: ResourceTimeboxEvent.actions[action],
                    iteration_id: iteration.blank? ? old_iteration_id : iteration&.id
                  })
    end
  end
end
