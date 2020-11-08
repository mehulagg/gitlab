# frozen_string_literal: true

require 'ctags4ruby'

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            PREFERRED_METHODS = [
              ScopeOffset,
              Location,
            ]

            def self.highest_supported(file_path, line_start, line_end)
              PREFERRED_METHODS.each do |pref_method|
                return pref_method if pref_method.supports(file_path, line_start, line_end)
              end
            end
          end
        end
      end
    end
  end
end
