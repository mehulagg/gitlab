# frozen_string_literal: true

module EE
  module Enums
    module InternalId
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        override :usage_resources
        def usage_resources
          super.merge(requirements: 1000)
        end
      end
    end
  end
end
