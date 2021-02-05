# frozen_string_literal: true

module Gitlab
  module HookData
    class ProjectMemberBuilder < BaseBuilder
      alias_method :project_member, :object

        def build(event)
        [
          timestamps_data,
          project_member_data,
          event_data(event)
        ].reduce(:merge)
        end


        private

        def project_member_data(model)
          project = model.project || Project.unscoped.find(model.source_id)

          {
            project_name:                 project.name,
            project_path:                 project.path,
            project_path_with_namespace:  project.full_path,
            project_id:                   project.id,
            user_username:                model.user.username,
            user_name:                    model.user.name,
            user_email:                   model.user.email,
            user_id:                      model.user.id,
            access_level:                 model.human_access,
            project_visibility:           Project.visibility_levels.key(project.visibility_level_value).downcase
          }
        end
        def event_data(event)
        event_name =  case event
                      when :create
                        'user_add_to_team'
                      when :destroy
                        'user_remove_from_team'
                      when :update
                        'user_update_for_team'
                      end
        { event_name: event_name }
        end
    end
  end
end
