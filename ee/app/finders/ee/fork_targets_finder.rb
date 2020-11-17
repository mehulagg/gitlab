# frozen_string_literal: true

module EE
  module ForkTargetsFinder
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :execute
    # rubocop: disable CodeReuse/ActiveRecord
    def execute(options = {})
      targets = super

      root_group = project.group&.root_ancestor
      return targets unless root_group&.prevent_forking_outside_group?

      targets.where(id: root_group.self_and_descendants)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
