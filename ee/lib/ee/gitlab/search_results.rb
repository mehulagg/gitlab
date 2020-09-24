# frozen_string_literal: true

module EE
  module Gitlab
    module SearchResults
      extend ::Gitlab::Utils::Override

      private

      override :projects
      def projects
        super.with_compliance_framework_settings
      end
    end
  end
end
