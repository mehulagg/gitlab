# frozen_string_literal: true

module EE
  module API
    module Entities
      class LinkedEpic < Grape::Entity
        expose :id
        expose :iid
        expose :title
        expose :group_id
        expose :parent_id
        expose :has_children?, as: :has_children
        expose :has_issues?, as: :has_issues
        expose :reference do |epic|
          epic.to_reference(epic.parent.group)
        end

        expose :url do |epic|
          ::Gitlab::Routing.url_helpers.group_epic_url(epic.group, epic)
        end

        expose :relation_url do |epic|
          ::Gitlab::Routing.url_helpers.group_epic_link_url(epic.parent.group, epic.parent.iid, epic.id)
        end
      end
    end
  end
end
