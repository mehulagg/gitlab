# frozen_string_literal: true

module Security
  # Service for storing a given security report into the database.
  #
  class PerformAutoactionsService < ::BaseService
    attr_reader :vuln, :vuln_finding, :actions, :vuln_only

    def initialize(vuln, vuln_finding, actions, vuln_only: false)
      @vuln = vuln
      @vuln_finding = vuln_finding
      @actions = actions
      @vuln_only = vuln_only
    end

    def execute
      errors = perform_actions(errors)

      if !errors.empty?
        error(errors.join("\n"))
      else
        success
      end
    end

    def perform_actions(errors)
      return if actions.nil?

      handlers = {
        'state-change' => method(:perform_state_change_action)
      }

      actions.each do |action|
        type = action['type']
        unless handlers.key? type
          errors << "Invalid action: #{type.inspect}"
          next
        end

        unless handlers[type].call(action)
          errors << "Could not perform action #{type.inspect}"
          next
        end
      end
    end

    def perform_state_change_action(action)
      return false unless %w[to reason when].all? { |k| action.key?(k) }
      return false if action['to'] != 'dismissed'
      return false if vuln.dismissed?

      if vuln_only
        vuln.state = :dismissed
      else
        # TODO we need to use a different user! Is a security_bot user always
        # defined??
        Vulnerabilities::DismissService.new(
          vuln_finding.pipelines.last.user,
          vuln,
          action['reason'],
          dismiss_findings: true
        ).execute
      end

      true
    end

  end
end
