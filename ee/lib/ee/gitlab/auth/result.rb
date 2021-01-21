# frozen_string_literal: true

module EE
  module Gitlab
    module Auth
      module Result
        extend ::Gitlab::Utils::Override

        override :success?
        def success?
          geo? || super
        end

        def geo?
          type == :geo
        end
      end
    end
  end
end
