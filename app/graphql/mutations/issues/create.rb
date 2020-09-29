# frozen_string_literal: true

module Mutations
  module Issues
    class Create < BaseMutation
      include ResolvesProject

      graphql_name 'IssueCreate'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Project full path the issue is associated with'

      argument :title, GraphQL::STRING_TYPE,
               required: true,
               description: copy_field_description(Types::IssueType, :title)

      argument :description, GraphQL::STRING_TYPE,
               required: false,
               description: copy_field_description(Types::IssueType, :description)

      argument :iid, GraphQL::INT_TYPE,
               required: false,
               description: 'The internal ID of a project issue. Available only for admins and project owners.'

      argument :labels, [GraphQL::STRING_TYPE],
               required: false,
               description: copy_field_description(Types::IssueType, :labels)

      argument :label_ids, [::Types::GlobalIDType[::Label]],
               required: false,
               description: 'The IDs of labels to be added to the issue.'

      argument :created_at, Types::TimeType,
               required: false,
               description: 'Date time when the issue was created. Available only for admins and project owners.'

      argument :merge_request_to_resolve_discussions_of, ::Types::GlobalIDType[::MergeRequest],
               required: false,
               description: 'The IID of a merge request for which to resolve discussions'

      argument :discussion_to_resolve, GraphQL::STRING_TYPE,
               required: false,
               description: 'The ID of a discussion to resolve, also pass `merge_request_to_resolve_discussions_of`'

      argument :assignee_ids, [::Types::GlobalIDType[::User]],
               required: false,
               description: 'The array of user IDs to assign issue'

      argument :milestone_id, ::Types::GlobalIDType[::Milestone],
               required: false,
               description: 'The ID of a milestone to assign issue'

      argument :due_date, GraphQL::Types::ISO8601Date,
               required: false,
               description: 'Date when issue is due.'

      argument :confidential, GraphQL::BOOLEAN_TYPE,
               required: false,
               description: 'Boolean parameter if the issue should be confidential'

      argument :discussion_locked, GraphQL::BOOLEAN_TYPE,
               required: false,
               description: " Boolean parameter indicating if the issue's discussion is locked"

      field :issue,
            Types::IssueType,
            null: true,
            description: 'The issue after mutation'

      authorize :create_issue

      def ready?(**args)
        if args.slice(*mutually_exclusive_args).size > 1
          arg_str = mutually_exclusive_args.map { |x| x.to_s.camelize(:lower) }.join(' or ')
          raise Gitlab::Graphql::Errors::ArgumentError, "one and only one of #{arg_str} is required"
        end

        super
      end

      def resolve(project_path:, **attributes)
        project = authorized_find!(full_path: project_path)
        params = create_issue_params(attributes.merge(author_id: current_user.id))

        issue = ::Issues::CreateService.new(project, current_user, params).execute

        if issue.spam?
          issue.errors.add(:base, _('Spam detected'))
        end

        {
          issue: issue.valid? ? issue : nil,
          errors: errors_on_object(issue)
        }
      end

      private

      def create_issue_params(params)
        params[:milestone_id] &&= ::GitlabSchema.parse_gid(params[:milestone_id], expected_type: ::Milestone).model_id
        params[:assignee_ids] &&= params[:assignee_ids].map { |assignee_id| ::GitlabSchema.parse_gid(assignee_id, expected_type: ::User).model_id }
        params[:label_ids] &&= params[:label_ids].map { |label_id| ::GitlabSchema.parse_gid(label_id, expected_type: ::Label).model_id }

        params
      end

      def mutually_exclusive_args
        [:labels, :label_ids]
      end

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end

Mutations::Issues::Create.prepend_if_ee('::EE::Mutations::Issues::Create')
