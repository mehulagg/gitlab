# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Report
          UNSAFE_SEVERITIES = %w[unknown high critical].freeze

          attr_reader :created_at
          attr_reader :type
          attr_reader :commit_sha
          attr_reader :findings
          attr_reader :scanners
          attr_reader :identifiers

          attr_accessor :scanned_resources
          attr_accessor :error

          def initialize(type, commit_sha, created_at)
            @type = type
            @commit_sha = commit_sha
            @created_at = created_at
            @findings = []
            @scanners = {}
            @identifiers = {}
            @scanned_resources = []
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
            Report.new(type, commit_sha, created_at)
          end

          def replace_with!(other)
            instance_variables.each do |ivar|
              instance_variable_set(ivar, other.public_send(ivar.to_s[1..-1])) # rubocop:disable GitlabSecurity/PublicSend
            end
          end

          def merge!(other)
            replace_with!(::Security::MergeReportsService.new(self, other).execute)
          end

          def unsafe_severity?
            !safe?
          end

          def safe?
            severities = findings.map(&:severity).compact.map(&:downcase)
            (severities & UNSAFE_SEVERITIES).empty?
          end
        end
      end
    end
  end
end
