# frozen_string_literal: true

module Auditable
  def push_audit_event(event)
    return unless ::Gitlab::Audit::EventQueue.active?

    ::Gitlab::Audit::EventQueue.push(event)
  end

  def audit_details
    raise NotImplementedError
  end
end
