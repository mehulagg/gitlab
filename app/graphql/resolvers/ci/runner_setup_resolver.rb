# frozen_string_literal: true

module Resolvers
  module Ci
    class RunnerSetupResolver < BaseResolver
      type Types::Ci::RunnerSetupType, null: true

      argument :platform, GraphQL::STRING_TYPE,
        required: true,
        description: "A description of the argument"

      argument :architecture, GraphQL::STRING_TYPE,
        required: true,
        description: "A description of the argument"

      def resolve(platform:, architecture:)
        instructions = Gitlab::Ci::RunnerInstructions.new(current_user: current_user, os: platform, arch: architecture)

        {
          install_instructions: instructions.install_script,
          register_instructions: instructions.register_command
        }
      end
    end
  end
end
