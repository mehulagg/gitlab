# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            SOURCE_METHODS = [
              Tracking::Source::Location,
              Tracking::Source::ScopeOffset
            ].freeze
          end
        end
      end
    end
  end
end
