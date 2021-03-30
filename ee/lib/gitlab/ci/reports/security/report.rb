# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Report
          attr_reader :created_at, :type, :pipeline, :findings, :scanners, :identifiers, :errors
          attr_accessor :scan, :scanned_resources

          delegate :project_id, to: :pipeline

          def initialize(type, pipeline, created_at)
            @type = type
            @pipeline = pipeline
            @created_at = created_at
            @findings = []
            @scanners = {}
            @identifiers = {}
            @scanned_resources = []
            @errors = []
          end

          def commit_sha
            pipeline.sha
          end

          def errored?
            errors.present?
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

          def primary_scanner
            scanners.first&.second
          end
        end
      end
    end
  end
end
