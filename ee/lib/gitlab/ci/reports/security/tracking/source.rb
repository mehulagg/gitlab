# frozen_string_literal: true

require 'ctags4ruby'

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          class Source < Base
            attr_reader :file_path
            attr_reader :start_line
            attr_reader :end_line

            def initialize(repository, sha, file_path, start_line, end_line:)
              @repository = repository
              @sha = sha
              @file_path = file_path
              @start_line = start_line
              @end_line = end_line || @start_line
            end

            private

            def fingerprint_data
              blob = @repository.blob_at(@sha, @file_path)
              scope_info = Ctags4Ruby.ctags4content(blob.data, "tmp/#{@file_path}")
              scope_loc = scope_location_for_line(scope_info, @start_line, @end_line)
              "#{@file_path}:#{scope_loc}"
            end

            def scope_location_for_line(scope_data, start_line, end_line)
              scope_path = []
              scope_data.each do |scope|
                if scope['line'] <= start_line && start_line <= scope['end']
                  scope_path << scope
                end
              end

              scope_start_offset = start_line - scope_path.last['line']
              scope_end_offset = end_line - scope_path.last['line']
              scope_path_str = scope_path.map{ |scope| scope['name'] }.join(':')
              "#{scope_path_str}:#{scope_start_offset}:#{scope_end_offset}"
            end
          end
        end
      end
    end
  end
end
