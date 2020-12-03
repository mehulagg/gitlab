# frozen_string_literal: true

module Ci
  module Minutes
    class Context
      delegate :shared_runners_minutes_limit_enabled?, to: :level
      delegate :name, to: :namespace, prefix: true
      delegate :shared_runners_remaining_minutes_percent, to: :namespace

      attr_reader :level

      def initialize(project, namespace)
        @project = project
        @namespace = project&.shared_runners_limit_namespace || namespace
        @level = project || namespace
      end

      private

      attr_reader :project, :namespace
    end
  end
end
