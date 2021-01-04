# frozen_string_literal: true

module API
  module Entities
    class SharedGroupWithGroup < Grape::Entity
      expose :shared_group_id, as: :group_id
      expose :group_name do |group_link|
        group_link.shared_group.name
      end
      expose :group_full_path do |group_link|
        group_link.shared_group.full_path
      end
      expose :group_access, as: :group_access_level
      expose :expires_at
    end
  end
end
