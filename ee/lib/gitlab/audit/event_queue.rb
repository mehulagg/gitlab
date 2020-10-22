# frozen_string_literal: true

module Gitlab
  module Audit
    module EventQueue
      module_function

      def begin!
        ::Gitlab::SafeRequestStore[:audit_active] = true
      end

      def current
        ::Gitlab::SafeRequestStore[:audit] ||= []
      end

      def push(event)
        current << event
      end

      def active?
        ::Gitlab::SafeRequestStore[:audit_active] || false
      end

      def end!
        ::Gitlab::SafeRequestStore.delete(:audit)
        ::Gitlab::SafeRequestStore.delete(:audit_active)
      end
    end
  end
end
