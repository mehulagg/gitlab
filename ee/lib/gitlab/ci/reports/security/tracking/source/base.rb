# frozen_string_literal: true

require 'ctags4ruby'

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            class Base < Tracking::Base
              def self.supports(filepath, line_start, line_end)
                raise NotImplementedError
              end

              def initialize(repository, sha, file_path, line_start, line_end)
                @repository = repository
                @sha = sha
                @file_path = file_path
                @line_start = line_start
                @line_end = line_end || line_start
              end

              def fingerprint_type
                Vulnerabilities::TrackingFingerprint.type_source
              end

              def fingerprint_data
                raise NotImplementedError.new('fingerprint_data must be implemented')
              end
            end
          end
        end
      end
    end
  end
end
