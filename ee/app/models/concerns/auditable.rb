# frozen_string_literal: true

module Auditable
  def push_audit_event(event)
    return unless ::Gitlab::Audit::EventQueue.active?

    ::Gitlab::Audit::EventQueue.current << event
  end
end
