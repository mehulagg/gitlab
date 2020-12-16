# frozen_string_literal: true

module EE
  module BoardSimpleEntity
    extend ActiveSupport::Concern

    prepended do
      expose :milestone, using: EE::TimeboxSimpleEntity, if: ->(board, _) { board&.milestone_id }
      expose :iteration, using: EE::TimeboxSimpleEntity, if: ->(board, _) { board&.iteration_id }
    end
  end
end
