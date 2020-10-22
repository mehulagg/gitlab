# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Create < BaseMutation
            ADMIN_MESSAGE = 'You must be an admin to use this mutation'

            graphql_name 'CreateDevopsAdoptionSegment'

            argument :name, GraphQL::STRING_TYPE,
              required: true,
              description: 'Name of the segment'

            argument :group_ids, [::Types::GlobalIDType[::Group]],
              required: false,
              description: 'The array of group IDs to set for the segment'

            field :segment,
                  Types::Admin::Analytics::DevopsAdoption::SegmentType,
                  null: true,
                  description: 'Information about the status of the deletion request'

            def ready?(**args)
              unless current_user&.admin?
                raise Gitlab::Graphql::Errors::ResourceNotAvailable, ADMIN_MESSAGE
              end

              super
            end

            def resolve(name:, group_ids: [], **)
              params = build_params(name: name, group_ids: group_ids)
              segment = ::Analytics::DevopsAdoption::Segment.create(params)

              {
                segment: segment.persisted? ? segment : nil,
                errors: errors_on_object(segment)
              }
            end

            private

            def build_params(params)
              group_ids = Array(params.delete(:group_ids)).map(&:model_id)

              return params if group_ids.empty?

              groups = ::Group.by_id(group_ids)
              selection_attributes = groups.map { |group| { group: group } }

              params[:segment_selections_attributes] = selection_attributes
              params
            end
          end
        end
      end
    end
  end
end
