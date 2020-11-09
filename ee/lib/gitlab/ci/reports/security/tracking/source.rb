# frozen_string_literal: true

require 'ctags4ruby'

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            SOURCE_METHODS = [
              Tracking::Source::Location,
              Tracking::Source::ScopeOffset,
            ].freeze

            def self.highest_supported(file_path, line_start, line_end)
              SOURCE_METHODS.sort_by(&:priority).reverse.each do |source_method|
                return source_method if source_method.supports(file_path, line_start, line_end)
              end
            end
          end
        end
      end
    end
  end
end
