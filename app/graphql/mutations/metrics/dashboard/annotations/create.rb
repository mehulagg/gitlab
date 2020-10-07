# frozen_string_literal: true

module Mutations
  module Metrics
    module Dashboard
      module Annotations
        class Create < BaseMutation
          graphql_name 'CreateAnnotation'

          ANNOTATION_SOURCE_ARGUMENT_ERROR = 'Either a cluster or environment global id is required'
          INVALID_ANNOTATION_SOURCE_ERROR = 'Invalid cluster or environment id'

          authorize :create_metrics_dashboard_annotation

          field :annotation,
            Types::Metrics::Dashboards::AnnotationType,
            null: true,
            description: 'The created annotation'

          argument :environment_id,
            GraphQL::ID_TYPE,
            required: false,
            description: 'The global id of the environment to add an annotation to'

          argument :cluster_id,
            GraphQL::ID_TYPE,
            required: false,
            description: 'The global id of the cluster to add an annotation to'

          argument :starting_at, Types::TimeType,
            required: true,
            description: 'Timestamp indicating starting moment to which the annotation relates'

          argument :ending_at, Types::TimeType,
            required: false,
            description: 'Timestamp indicating ending moment to which the annotation relates'

          argument :dashboard_path,
            GraphQL::STRING_TYPE,
            required: true,
            description: 'The path to a file defining the dashboard on which the annotation should be added'

          argument :description,
            GraphQL::STRING_TYPE,
            required: true,
            description: 'The description of the annotation'

          AnnotationSource = Struct.new(:object, keyword_init: true) do
            def type_keys
              { 'Clusters::Cluster' => :cluster, 'Environment' => :environment }
            end

            def klass
              object.class.name
            end

            def type
              raise Gitlab::Graphql::Errors::ArgumentError, INVALID_ANNOTATION_SOURCE_ERROR unless type_keys[klass]

              type_keys[klass]
            end
          end

          def resolve(args)
            annotation_response = ::Metrics::Dashboard::Annotations::CreateService.new(context[:current_user], annotation_create_params(args)).execute

            annotation = annotation_response[:annotation]

            {
              annotation: annotation.valid? ? annotation : nil,
              errors: errors_on_object(annotation)
            }
          end

          private

          def ready?(**args)
            # Raise error if both cluster_id and environment_id are present or neither is present
            unless args[:cluster_id].present? ^ args[:environment_id].present?
              raise Gitlab::Graphql::Errors::ArgumentError, ANNOTATION_SOURCE_ARGUMENT_ERROR
            end

            super(**args)
          end

          def find_object(id:)
            GitlabSchema.object_from_id(id)
          end

          def annotation_create_params(args)
            annotation_source = AnnotationSource.new(object: annotation_source(args))

            args[annotation_source.type] = annotation_source.object

            args
          end

          def annotation_source(args)
            annotation_source_id = args[:cluster_id] || args[:environment_id]
            authorized_find!(id: annotation_source_id)
          end
        end
      end
    end
  end
end
