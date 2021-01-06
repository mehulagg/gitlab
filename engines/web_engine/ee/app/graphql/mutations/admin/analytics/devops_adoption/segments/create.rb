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
              groups = GlobalID::Locator.locate_many(group_ids)

              response = ::Analytics::DevopsAdoption::Segments::CreateService
                .new(current_user: current_user, params: { name: name, groups: groups })
                .execute

              resolve_segment(response)
            end
          end
        end
      end
    end
  end
end
