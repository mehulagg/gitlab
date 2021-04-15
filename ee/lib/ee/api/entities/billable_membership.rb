# frozen_string_literal: true

module EE
  module API
    module Entities
      class BillableMembership < Grape::Entity
        include ::Gitlab::Routing

        expose :id
        expose :source_id
        expose :source_full_name do |member|
          member.source.full_name
        end
        expose :source_members_url do |member|
          case member.source_type
          when 'Namespace'
            group_group_members_url(member.source)
          when 'Project'
            project_project_members_url(member.source)
          end
        end
        expose :created_at
        expose :expires_at
        expose :access_level do
          expose :human_access, as: :string_value
          expose :access_level, as: :integer_value
        end
      end
    end
  end
end
