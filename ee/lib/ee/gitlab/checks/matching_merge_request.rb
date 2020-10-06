# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module MatchingMergeRequest
        extend ::Gitlab::Utils::Override

        override :match?
        def match?
          return super unless ::Feature.enabled?(:matching_merge_request_db_sync)
          return super unless ::Gitlab::Database::LoadBalancing.enable?

          # When a user merges a merge request, the following sequence happens:
          #
          # 1. Sidekiq: MergeService runs and updates the merge request in a locked state.
          # 2. Gitaly: The UserMergeBranch RPC runs.
          # 3. Gitaly (gitaly-ruby): This RPC calls the pre-receive hook.
          # 4. Rails: This hook makes an API request to /api/v4/internal/allowed.
          # 5. Rails: This API check does a SQL query for locked merge
          #    requests with a matching SHA.
          #
          # Since steps 1 and 5 will happen on different database
          # sessions, replication lag could erroneously cause step 5 to
          # report no matching merge requests. To avoid this, we check
          # the write location to ensure the replica can make this query.
          ::Gitlab::Database::LoadBalancing::Sticking.unstick_or_continue_sticking(:project, @project.id) # rubocop:disable Gitlab/ModuleWithInstanceVariables
          super
        end
      end
    end
  end
end
