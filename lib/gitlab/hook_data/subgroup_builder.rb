# frozen_string_literal: true

module Gitlab
  module HookData
    class SubgroupBuilder < GroupBuilder
      # Sample data
      # {
      #  :created_at=>"2021-01-20T09:40:12Z",
      #  :updated_at=>"2021-01-20T09:40:12Z",
      #  :event_name=>"subgroup_create",
      #  :name=>"group1",
      #  :path=>"group1",
      #  :full_path=>"group1",
      #  :group_id=>1,
      # }

      # TODO: Add proper example data

      private

      def event_data(event)
        event_name =  case event
                      when :create
                        'subgroup_create'
                      when :destroy
                        'subgroup_destroy'
                      end

        { event_name: event_name }
      end

      def group_data
        parent = group.parent

        super.merge(
          parent_group_id: parent.id,
          parent_name: parent.name,
          parent_path: parent.path,
          parent_full_path: parent.full_path
        )
      end
    end
  end
end
