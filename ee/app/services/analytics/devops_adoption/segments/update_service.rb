# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class UpdateService < CreateService
        extend ::Gitlab::Utils::Override

        private

        override :segment_selections_attributes
        def segment_selections_attributes
          return if params[:groups].nil?

          existing_selections_by_group_id = segment.segment_selections.index_by(&:group_id)
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

          selection_attributes
        end
      end
    end
  end
end
