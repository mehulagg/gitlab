# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class CreateService
        def initialize(segment: Analytics::DevopsAdoption::Segment.new, params: {})
          @segment = segment
          @params = params
        end

        def execute
          @segment.assign_attributes(attributes)
          @segment.tap(&:save)
        end

        private

        attr_reader :segment, :params

        def attributes
          { name: params[:name], segment_selections_attributes: segment_selections_attributes }.compact
        end

        def segment_selections_attributes
          groups.map { |group| { group: group } }
        end

        def groups
          @groups ||= begin
                        group_ids = Array(params[:group_ids])
                          .uniq
                          .first(::Analytics::DevopsAdoption::SegmentSelection::ALLOWED_SELECTIONS_PER_SEGMENT)

                        ::Group.by_id(group_ids).to_a
                      end
        end
      end
    end
  end
end
