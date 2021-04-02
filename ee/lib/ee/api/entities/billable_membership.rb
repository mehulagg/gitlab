# frozen_string_literal: true

module EE
  module API
    module Entities
      class BillableMembership < Grape::Entity
        expose :source_full_name do |member|
          member.source.full_name
        end
        expose :created_at
        expose :expires_at do |member|
          member.expires_at
        end
        expose :access_level do
          expose :human_access, as: :string_value
          expose :access_level, as: :integer_value
        end
      end
    end
  end
end
