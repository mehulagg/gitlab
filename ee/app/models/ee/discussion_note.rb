# frozen_string_literal: true

module EE
  module DiscussionNote
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      override :noteable_types
      def noteable_types
        super + %w[Epic Vulnerability]
      end
    end
  end
end
