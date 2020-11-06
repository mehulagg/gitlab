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
          @groups ||= Array(params[:groups]).uniq
        end
      end
    end
  end
end
