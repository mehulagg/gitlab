# frozen_string_literal: true

module Mutations
  module Vulnerability
    class CreateMergeRequest < BaseMutation
      graphql_name 'VulnerabilityCreateMergeRequest'

      authorize :admin_vulnerability

      field :merge_request_feedback, Types::Vulnerability::MergeRequestFeedbackType,
            null: true,
            description: 'The feedback from the created merge request'

      argument :id,
                ::Types::GlobalIDType[::Vulnerability],
                required: true,
                description: 'ID of the vulnerability to create feedback for'

      argument :project_id,
                GraphQL::INT_TYPE,
                required: true,
                description: 'Pipeline ID where vulnerability was found'

      argument :project_fingerprint,
               GraphQL::STRING_TYPE,
               required: true,
               description: 'Fingerprint of project vulnerability was found in'

      argument :category,
               ::Types::VulnerabilityReportTypeEnum,
               required: true,
               description: 'Category (report type) of vulnerability'

      argument :pipeliine_id,
               GraphQL::INT_TYPE,
               required: true,
               description: 'Pipeline ID where vulnerability was found'

      argument :vulnerability_data,
               ::Types::VulnerabilityType,
               required: true,
               description: 'Vulnerability data'

      def resolve(category:, project_id:, author_id:, pipeline_id:, project_fingerprint:, vulnerability_data:)
        vulnerability_feedback_params = {
          feedback_type: 'merge_request',
          category: category,
          project_fingerprint: project_fingerprint,
          pipeline_id: pipeline_id,
          vulnerability_data: vulnerability_data
        }

        project = authorized_find!(id: project_id)
        result = create_feedback(project, vulnerability_feedback_params)

        {
          vulnerability: result,
          errors: result.errors.full_messages || []
        }
      end

      private

      def create_feedback(project, vulnerability_feedback_params)
        service = VulnerabilityFeedback::CreateService.new(project, current_user, vulnerability_feedback_params)
        result = service.execute

        {
          vulnerability_feedback: result,
          errors: result.errors.full_messages || []
        }
      end

      def find_object(id:)
        # TODO: remove this line once the compatibility layer is removed.
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        id = ::Types::GlobalIDType[::Vulnerability].coerce_isolated_input(id)
        GitlabSchema.find_by_gid(id)
      end

      def find_project(id:)
        # TODO: remove this line once the compatibility layer is removed.
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        id = ::Types::GlobalIDType[::Project].coerce_isolated_input(id)
        GitlabSchema.find_by_gid(id)
      end
    end
  end
end
