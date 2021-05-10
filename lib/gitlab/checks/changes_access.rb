# frozen_string_literal: true

module Gitlab
  module Checks
    class ChangesAccess
      ATTRIBUTES = %i[user_access project protocol changes logger].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(
        changes, user_access:, project:, protocol:, logger:
      )
        @changes = changes
        @user_access = user_access
        @project = project
        @protocol = protocol

        @logger = logger
        @logger.append_message("Running checks for #{@changes.length()} changes")
      end

      def validate!
        checks

        true
      end

      protected

      def checks
      end
    end
  end
end
