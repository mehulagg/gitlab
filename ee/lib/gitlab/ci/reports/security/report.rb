# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Report
          attr_reader :created_at
          attr_reader :type
          attr_reader :pipeline
          attr_reader :findings
          attr_reader :scanners
          attr_reader :identifiers

          attr_accessor :scan
          attr_accessor :scanned_resources
          attr_accessor :error

          def initialize(type, pipeline, created_at)
            @type = type
            @pipeline = pipeline
            @created_at = created_at
            @findings = []
            @scanners = {}
            @identifiers = {}
            @scanned_resources = []
          end

          def commit_sha
            pipeline.sha
          end

          def errored?
            error.present?
          end

          def add_scanner(scanner)
            scanners[scanner.key] ||= scanner
          end

          def add_identifier(identifier)
            identifiers[identifier.key] ||= identifier
          end

          def add_finding(finding)
            findings << finding
          end

          def clone_as_blank
            Report.new(type, pipeline, created_at)
          end

          def replace_with!(other)
            instance_variables.each do |ivar|
              instance_variable_set(ivar, other.public_send(ivar.to_s[1..-1])) # rubocop:disable GitlabSecurity/PublicSend
            end
          end

          def merge!(other)
            replace_with!(::Security::MergeReportsService.new(self, other).execute)
          end
        end
      end
    end
  end
end
