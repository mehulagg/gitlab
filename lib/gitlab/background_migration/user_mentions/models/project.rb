# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    module UserMentions
      module Models
        # isolated Namespace model
        class Project < ApplicationRecord
          self.table_name = 'projects'

          belongs_to :group, -> { where(type: 'Group') }, foreign_key: 'namespace_id', class_name: "::Gitlab::BackgroundMigration::UserMentions::Models::Group"
          belongs_to :namespace, class_name: "::Gitlab::BackgroundMigration::UserMentions::Models::Namespace"
          alias_method :parent, :namespace

          # Returns a collection of projects that is either public or visible to the
          # logged in user.
          def self.public_or_visible_to_user(user = nil, min_access_level = nil)
            min_access_level = nil if user&.admin?

            return public_to_user unless user

            if user.is_a?(DeployToken)
              user.projects
            else
              where('EXISTS (?) OR projects.visibility_level IN (?)',
                    user.authorizations_for_projects(min_access_level: min_access_level),
                    Gitlab::VisibilityLevel.levels_for_user(user))
            end
          end

        end
      end
    end
  end
end
