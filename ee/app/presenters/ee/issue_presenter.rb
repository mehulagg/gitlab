# frozen_string_literal: true

module EE
  module IssuePresenter
    extend ActiveSupport::Concern

    def sla_due_at
      return unless sla_available?

      incident_sla&.due_at
    end
  end
end
