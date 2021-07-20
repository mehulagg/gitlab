# frozen_string_literal: true

module EE
  module API
    module Entities
      class BillableMembership < Grape::Entity
        include RequestAwareEntity

        expose :id
        expose :source_id
        expose :source_full_name do |member|
          member.source.full_name
        end
        expose :source_members_url do |member|
          source_members_url(member)
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
