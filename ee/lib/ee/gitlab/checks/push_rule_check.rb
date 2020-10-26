# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      class PushRuleCheck < ::Gitlab::Checks::BaseChecker
        def validate!
          return unless push_rule

          if ::Feature.enabled?(:parallel_push_checks, project, type: :ops)
            run_checks_in_parallel!
          else
            run_checks_in_sequence!
          end
        end

        private

        # @return [Nil] returns nil unless an error is raised
        # @raise [Gitlab::GitAccess::ForbiddenError] if check fails
        def check_tag_or_branch!
          if tag_name
            PushRules::TagCheck.new(change_access).validate!
          else
            PushRules::BranchCheck.new(change_access).validate!
          end
        end

        # @return [Nil] returns nil unless an error is raised
        # @raise [Gitlab::GitAccess::ForbiddenError] if check fails
        def check_file_size!
          PushRules::FileSizeCheck.new(change_access).validate!
        end

        # Run the checks one after the other.
        #
        # @return [Nil] returns nil unless an error is raised
        # @raise [Gitlab::GitAccess::ForbiddenError] if any check fails
        def run_checks_in_sequence!
          check_tag_or_branch!
          check_file_size!
        end

        # Run the checks in separate threads for performance benefits
        #
        # @return [Nil] returns nil unless an error is raised
        # @raise [Gitlab::GitAccess::ForbiddenError] if any check fails
        def run_checks_in_parallel!
          @threads = []

          parallelize do
            check_tag_or_branch!
          end

          parallelize do
            check_file_size!
          end

          # Block whilst waiting for threads, however if one errors
          # it will exit early and raise the error immediately as
          # we set `abort_on_exception` to true.
          @threads.each(&:join)

          nil
        ensure
          # We want to make sure no threads are left dangling.
          # Threads can exit early when an exception is raised
          # and so we want to ensure any still running are exited
          # as soon as possible.
          @threads.each(&:exit)
        end

        # Runs a block inside a new thread. This thread will
        # exit immediately upon an exception being raised.
        #
        # @raise [Gitlab::GitAccess::ForbiddenError]
        def parallelize
          @threads << Thread.new do
            Thread.current.tap do |t|
              t.name = "push_rule_check"
              t.abort_on_exception = true
              t.report_on_exception = false
            end

            yield
          ensure # rubocop: disable Layout/RescueEnsureAlignment
            ActiveRecord::Base.clear_active_connections!
          end
        end
      end
    end
  end
end
