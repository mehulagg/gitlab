# frozen_string_literal: true

require 'ctags4ruby'

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            class ScopeOffset < Source::Base
              def self.supports(file_path, line_start, line_end)
                return true
              end

              def self.priority
                Vulnerabilities::TrackingFingerprint.priority_source_scope_offset
              end

              def fingerprint_method
                Vulnerabilities::TrackingFingerprint.method_scope_offset
              end

              def fingerprint_data
                blob = @repository.blob_at(@sha, @file_path)
                scope_info = Ctags4Ruby.ctags4content(blob.data, "tmp/#{@file_path}")

                scope_loc = scope_location_for_line(scope_info, @line_start, @line_end)
                "#{@file_path}:#{scope_loc}"
              end

              def scope_location_for_line(scope_data, line_start, line_end)
                scope_path = []
                scope_data.each do |scope|
                  scope = scope.to_hash
                  if scope['lineNumber'] <= line_start && line_start <= scope['endLine']
                    scope_path << scope
                  end
                end

                scope_start_offset = line_start - scope_path.last['lineNumber']
                scope_end_offset = line_end - scope_path.last['lineNumber']
                scope_path_str = scope_path.map{ |scope| scope['scopeName'] }.join(':')
                "#{scope_path_str}:#{scope_start_offset}:#{scope_end_offset}"
              end
            end
          end
        end
      end
    end
  end
end
