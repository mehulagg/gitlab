# frozen_string_literal: true

module Mutations
  module Boards
    module Lists
      class UpdateLimitMetrics < ::Mutations::BaseMutation
        graphql_name 'BoardListUpdateLimitMetrics'

        argument :list_id,
                 GraphQL::ID_TYPE,
                 required: true,
                 description: 'The global ID of the list.'

        argument :limit_metric,
                 EE::Types::ListLimitMetricEnum,
                 required: false,
                 description: 'The new limit metric type for the list.'

        argument :max_issue_count,
                 GraphQL::INT_TYPE,
                 required: false,
                 description: 'The new maximum issue count limit.'

        argument :max_issue_weight,
                 GraphQL::INT_TYPE,
                 required: false,
                 description: 'The new maximum issue weight limit.'

        field :list,
              ::Types::BoardListType,
              null: true,
              description: 'The updated list'

        def ready?(**args)
          if limit_metric_settings_of(args).blank?
            raise Gitlab::Graphql::Errors::ArgumentError,
                  'At least one of the arguments limitMetric, maxIssueCount or maxIssueWeight is required'
          end

          super
        end

        def resolve(**args)
          find_list_by_args!(args)

          update_result = update_list(args)

          {
            list: update_result[:list],
            errors: list.errors.full_messages
          }
        end

        private

        attr_reader :list

        def find_list_by_args!(args)
          @list ||= find_list_by_global_id(args[:list_id])

          raise_resource_not_available_error! unless list

          authorize_admin_rights!
        end

        def update_list(args)
          service = ::Boards::Lists::UpdateService.new(board, current_user, limit_metric_settings_of(args))
          service.execute(list)
        end

        def authorize_admin_rights!
          raise_resource_not_available_error! unless Ability.allowed?(current_user, :admin_list, board)
        end

        def find_list_by_global_id(gid)
          parsed_gid = GlobalID.parse(gid)
          id = parsed_gid.model_id.to_i if list_accessible?(parsed_gid)
          return unless id

          List.find_by_id(id)
        end

        def list_accessible?(gid)
          gid.app == GlobalID.app && list?(gid)
        end

        def list?(gid)
          model_class = gid&.model_class
          return unless model_class

          model_class <= List
        end

        def board
          @board ||= list.board
        end

        def limit_metric_settings_of(args)
          args.slice(:limit_metric, :max_issue_count, :max_issue_weight)
        end
      end
    end
  end
end
