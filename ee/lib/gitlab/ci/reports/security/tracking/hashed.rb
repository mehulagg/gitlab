# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          class Hashed < Base
            attr_reader :data

            def initialize(data:)
              @data = data
            end

            private

            def fingerprint_data
              @data.to_s
            end
          end
        end
      end
    end
  end
end
