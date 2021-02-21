# frozen_string_literal: true

module Mutations
  module MergeRequests
    class Merge < Base
      NOT_MERGEABLE = 'This branch cannot be merged'
      HOOKS_VALIDATION_ERROR = 'Pre-merge hooks failed'
      SHA_MISMATCH = 'The merge-head is not at the anticipated SHA'
      MERGE_FAILED = 'The merge failed'

      graphql_name 'MergeRequestAccept'
      authorize :accept_merge_request

      argument :strategy,
               ::Types::MergeStrategyEnum,
               required: false,
               as: :auto_merge_strategy,
               description: 'How to merge this merge request.'

      argument :commit_message, ::GraphQL::STRING_TYPE, required: false,
               description: 'Custom merge commit message.'
      argument :squash_commit_message, ::GraphQL::STRING_TYPE, required: false,
               description: 'Custom squash commit message (if squash is true).'
      argument :sha, ::GraphQL::STRING_TYPE, required: true,
               description: 'The HEAD SHA at the time when this merge was requested.'

      argument :should_remove_source_branch, ::GraphQL::BOOLEAN_TYPE,
               required: false,
               description: 'Should the source branch be removed.'
      argument :force_remove_source_branch, ::GraphQL::BOOLEAN_TYPE,
               required: false,
               description: 'Force the source branch to be removed.'
      argument :squash, ::GraphQL::BOOLEAN_TYPE,
               required: false,
               default_value: false,
               description: 'Squash commits on the source branch before merge.'

      def resolve(project_path:, iid:, **args)
        merge_request = authorized_find!(project_path: project_path, iid: iid)
        project = merge_request.project
        merge_params = args.compact
        auto_merge_requested = merge_params.key?(:auto_merge_strategy)
        merge_service = ::MergeRequests::MergeService.new(project, current_user, merge_params)

        if error = validate(merge_request, merge_service, merge_params)
          return { merge_request: merge_request, errors: [error] }
        end

        merge_request.update(merge_error: nil, squash: merge_params[:squash])

        result = if auto_merge_requested
                   service = AutoMergeService.new(project, current_user, merge_params)
                   if merge_request.auto_merge_enabled?
                     service.update(merge_request)
                   else
                     service.execute(merge_request, merge_params[:auto_merge_strategy])
                   end
                 else
                   merge_service.execute(merge_request)
                 end

        errors = if result == :failed
                   [MERGE_FAILED]
                 else
                   []
                 end

        {
          merge_request: merge_request,
          errors: errors
        }
      rescue MergeError => e
        {
          merge_request: merge_request,
          errors: [e.message]
        }
      end

      def validate(merge_request, merge_service, merge_params)
        if !merge_request.mergeable?(skip_ci_check: merge_params.key?(:auto_merge_strategy))
          NOT_MERGEABLE
        elsif !merge_service.hooks_validation_pass?(merge_request)
          HOOK_VALIDATION_ERROR
        elsif merge_params[:sha] != merge_request.diff_head_sha
          SHA_MISMATCH
        end
      end
    end
  end
end
