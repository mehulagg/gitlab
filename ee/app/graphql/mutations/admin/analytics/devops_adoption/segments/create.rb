# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Create < BaseMutation
            include Mixins::CommonMethods
            include Mixins::CommonArguments

            graphql_name 'CreateDevopsAdoptionSegment'

            def resolve(name:, group_ids: [], **)
              segment = ::Analytics::DevopsAdoption::Segments::CreateService
                .new(params: { name: name, group_ids: to_numeric_ids(group_ids) }.compact)
                .execute

              resolve_segment(segment)
            end
          end
        end
      end
    end
  end
end
