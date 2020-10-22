# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          module Mixins
            # This module ensures that the mutations are admin only
            module RequireAdminPermission
              ADMIN_MESSAGE = 'You must be an admin to use this mutation'

              def ready?(**args)
                unless current_user&.admin?
                  raise Gitlab::Graphql::Errors::ResourceNotAvailable, ADMIN_MESSAGE
                end

                super
              end
            end

            # This module builds the nested attributes for `segment_selections`
            module BuildParams
              # rubocop: disable CodeReuse/ActiveRecord
              def build_params(params, existing_segment_selections = [])
                if params[:group_ids].nil?
                  params.delete(:group_ids)
                  return params
                end

                group_ids = Array(params.delete(:group_ids))
                  .take(::Analytics::DevopsAdoption::SegmentSelection::ALLOWED_SELECTIONS_PER_SEGMENT)
                  .map(&:model_id)

                groups = ::Group.by_id(group_ids)

                existing_selections_by_group_id = existing_segment_selections.index_by(&:group_id)
                groups_by_id = groups.index_by(&:id)

                selection_attributes = groups.map do |group|
                  { group: group }.tap do |attrs|
                    attrs[:id] = existing_selections_by_group_id[group.id].id if existing_selections_by_group_id[group.id]
                  end
                end

                existing_selections_by_group_id.each do |group_id, selection|
                  unless groups_by_id[group_id]
                    selection_attributes << { id: selection.id, _destroy: '1' }
                  end
                end

                params[:segment_selections_attributes] = selection_attributes
                params
              end
              # rubocop: enable CodeReuse/ActiveRecord
            end
          end
        end
      end
    end
  end
end
