# frozen_string_literal: true

module EE
  module DB
    module SchemaSupport
      extend ActiveSupport::Concern

      prepended do
        IGNORED_LIMIT_ENUMS = {
          'SoftwareLicensePolicy' => %w[classification],
          'User' => %w[group_view]
        }.freeze
      end

      def ignored_limit_enums(model)
        super + IGNORED_LIMIT_ENUMS.fetch(model, [])
      end
    end
  end
end
