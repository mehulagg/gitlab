# frozen_string_literal: true

module EE
  module Ci
    module RetryBuildService
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        override :clone_accessors
        def clone_accessors
          (super + %i[secrets]).freeze
        end
      end
    end
  end
end
