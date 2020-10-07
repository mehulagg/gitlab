# frozen_string_literal: true

module Types
  module Ci
    class PipelineType < BaseObject
      graphql_name 'Pipeline'

      connection_type_class(Types::CountableConnectionType)

      authorize :read_pipeline

      expose_permissions Types::PermissionTypes::Ci::Pipeline

      field :id, GraphQL::ID_TYPE, null: false,
            description: 'ID of the pipeline'
      field :iid, GraphQL::STRING_TYPE, null: false,
            description: 'Internal ID of the pipeline'

      field :sha, GraphQL::STRING_TYPE, null: false,
            description: "SHA of the pipeline's commit"
      field :before_sha, GraphQL::STRING_TYPE, null: true,
            description: 'Base SHA of the source branch'
      field :status, PipelineStatusEnum, null: false,
            description: "Status of the pipeline (#{::Ci::Pipeline.all_state_names.compact.join(', ').upcase})"
      field :detailed_status, Types::Ci::DetailedStatusType, null: false,
            description: 'Detailed status of the pipeline',
            resolve: -> (obj, _args, ctx) { obj.detailed_status(ctx[:current_user]) }
      field :config_source, PipelineConfigSourceEnum, null: true,
            description: "Config source of the pipeline (#{::Enums::Ci::Pipeline.config_sources.keys.join(', ').upcase})"
      field :duration, GraphQL::INT_TYPE, null: true,
            description: 'Duration of the pipeline in seconds'
      field :coverage, GraphQL::FLOAT_TYPE, null: true,
            description: 'Coverage percentage'
      field :created_at, Types::TimeType, null: false,
            description: "Timestamp of the pipeline's creation"
      field :updated_at, Types::TimeType, null: false,
            description: "Timestamp of the pipeline's last activity"
      field :started_at, Types::TimeType, null: true,
            description: 'Timestamp when the pipeline was started'
      field :finished_at, Types::TimeType, null: true,
            description: "Timestamp of the pipeline's completion"
      field :committed_at, Types::TimeType, null: true,
            description: "Timestamp of the pipeline's commit"
      field :stages, Types::Ci::StageType.connection_type, null: true,
            description: 'Stages of the pipeline',
            extras: [:lookahead],
            resolver: Resolvers::Ci::PipelineStagesResolver
      field :user, Types::UserType, null: true,
            description: 'Pipeline user',
            resolve: -> (pipeline, _args, _context) { Gitlab::Graphql::Loaders::BatchModelLoader.new(User, pipeline.user_id).find }
      field :retryable, GraphQL::BOOLEAN_TYPE,
            description: 'Specifies if a pipeline can be retried',
            method: :retryable?,
            null: false
      field :cancelable, GraphQL::BOOLEAN_TYPE,
            description: 'Specifies if a pipeline can be canceled',
            method: :cancelable?,
            null: false

      field :builds, [::Types::Ci::BuildType], null: true,
            description: 'Builds run in this pipeline' do
        argument :statuses, [::Types::Ci::BuildStatusEnum], required: false,
          as: :status,
          description: 'A list of build statuses. If non-empty, then filter the build to only those with one of these statuses'
      end

      field :build, ::Types::Ci::BuildType, null: true,
            description: 'A specific build in this pipeline, either by name or ID' do
        argument :id, ::Types::GlobalIDType[::Ci::Build], required: false,
          description: 'The ID of the build'
        argument :name, ::GraphQL::STRING_TYPE, required: false,
          description: 'The name of the build'
      end

      # This returns arrays because a downstream MR needs them to be so.
      # This method will be removed when https://gitlab.com/gitlab-org/gitlab/-/merge_requests/45263
      # is merged.
      def builds(status: nil)
        # NOTE: This method should be removed once the ci_jobs_finder_refactor FF is
        # removed. https://gitlab.com/gitlab-org/gitlab/-/issues/245183
        # rubocop: disable CodeReuse/ActiveRecord
        if Feature.enabled?(:ci_jobs_finder_refactor, default_enabled: true)
          params = { scope: status }
          ::Ci::JobsFinder
            .new(current_user: current_user, pipeline: pipeline, params: params)
            .execute
            .to_a
        else
          return ::Ci::Build.none unless can?(current_user, :read_build, pipeline)

          builds = pipeline.builds
          builds = builds.where(status: status) if status.present?
          builds.to_a
        end
      end

      def build(id: nil, name: nil)
        raise ::Gitlab::Graphql::Errors::ArgumentError, 'One of id or name is required' unless id || name

        id = ::Types::GlobalIDType[::Ci::Build].coerce_isolated_input(id) if id.present?
        args = { id: id&.model_id, name: name }

        pipeline.builds.find_by(args.compact)
      end

      alias_method :pipeline, :object

      # TODO: remove when the else branch of builds is removed
      def can?(object, action, subject = :global)
        Ability.allowed?(object, action, subject)
      end
    end
  end
end

Types::Ci::PipelineType.prepend_if_ee('::EE::Types::Ci::PipelineType')
