# frozen_string_literal: true

module DesignManagement
  class DeleteDesignsService < DesignService
    include RunsDesignActions
    include OnSuccessCallbacks

    def initialize(project, user, params = {})
      super

      @designs = params.fetch(:designs)
    end

    def execute
      return error('Forbidden!') unless can_delete_designs?

      actions = build_actions
      version = run_actions(actions, current_user)

      # Create a Geo event so changes will be replicated to secondary node(s)
      repository.log_geo_updated_event

      success(version: version)
    end

    def commit_message
      n = designs.size

      <<~MSG
      Removed #{n} #{'designs'.pluralize(n)}

      #{formatted_file_list}
      MSG
    end

    private

    attr_reader :designs

    def can_delete_designs?
      Ability.allowed?(current_user, :destroy_design, issue)
    end

    def build_actions
      designs.map { |d| design_action(d) }
    end

    def design_action(design)
      on_success { counter.count(:delete) }

      DesignManagement::DesignAction.new(design, :delete)
    end

    def counter
      ::Gitlab::UsageCounters::DesignsCounter
    end

    def formatted_file_list
      designs.map { |design| "- #{design.full_path}" }.join("\n")
    end
  end
end
