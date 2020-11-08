# frozen_string_literal: true

require 'ctags4ruby'

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            class Location < Source::Base
              def self.supports(file_path, line_start, line_end)
                true
              end

              def fingerprint_method
                "Location"
              end

              def fingerprint_data
                "#{@file_path}:#{@line_start}:#{@line_end}"
              end
            end
          end
        end
      end
    end
  end
end
