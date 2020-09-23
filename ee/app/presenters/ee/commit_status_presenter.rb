# frozen_string_literal: true
module EE
  module CommitStatusPresenter
    extend ActiveSupport::Concern

    prepended do
      EE_CALLOUT_FAILURE_MESSAGES = const_get(:CALLOUT_FAILURE_MESSAGES, false).merge(
        protected_environment_failure: 'The environment this job is deploying to is protected. Only users with permission may successfully run this job.',
        insufficient_upstream_permissions: 'This job could not be executed because of insufficient permissions to track the upstream project.',
        upstream_bridge_project_not_found: 'This job could not be executed because upstream bridge project could not be found.'
      ).freeze

      EE::CommitStatusPresenter.private_constant :EE_CALLOUT_FAILURE_MESSAGES
    end

    class_methods do
      def callout_failure_messages
        EE_CALLOUT_FAILURE_MESSAGES
      end
    end
  end
end
