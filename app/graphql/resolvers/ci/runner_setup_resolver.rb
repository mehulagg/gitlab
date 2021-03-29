# frozen_string_literal: true

module Resolvers
  module Ci
    class RunnerSetupResolver < BaseResolver
      type Types::Ci::RunnerSetupType, null: true
      description 'Runner setup instructions.'

      argument :platform, GraphQL::STRING_TYPE,
        required: true,
        description: 'Platform to generate the instructions for.'

      argument :architecture, GraphQL::STRING_TYPE,
        required: true,
        description: 'Architecture to generate the instructions for.'

      def resolve(platform:, architecture:)
        instructions = Gitlab::Ci::RunnerInstructions.new(
          current_user: current_user,
          os: platform,
          arch: architecture
        )

        {
          install_instructions: instructions.install_script || other_install_instructions(platform),
          register_instructions: instructions.register_command
        }
      end

      private

      def other_install_instructions(platform)
        Gitlab::Ci::RunnerInstructions::OTHER_ENVIRONMENTS[platform.to_sym][:installation_instructions_url]
      end
    end
  end
end
