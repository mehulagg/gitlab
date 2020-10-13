# frozen_string_literal: true

module Resolvers
  class RunnerSetupResolver < BaseResolver
    def resolve(**args)
      Gitlab::Ci::RunnerInstructions::OS.merge(Gitlab::Ci::RunnerInstructions::OTHER_ENVIRONMENTS)
    end
  end
end
