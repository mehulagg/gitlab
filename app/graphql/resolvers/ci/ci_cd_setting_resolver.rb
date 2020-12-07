# frozen_string_literal: true

module Resolvers
  module Ci
    class CiCdSettingResolver < BaseResolver
      type Types::Ci::CiCdSettingType, null: true

      alias_method :project, :object

      def resolve(**args)
        return unless project.is_a? Project

        project.ci_cd_settings
      end
    end
  end
end
