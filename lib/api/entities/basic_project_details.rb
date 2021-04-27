# frozen_string_literal: true

module API
  module Entities
    class BasicProjectDetails < Entities::ProjectIdentity
      include ::API::ProjectsRelationBuilder

      expose :default_branch, if: -> (project, options) { Ability.allowed?(options[:current_user], :download_code, project) }

      # Tag is ambiguous term so we deprecate it in favor of topics.
      # Documentation will mention topics but we keep exposing both
      # topics and tag_list in API until 15.0. After that we remove tag_list.
      # Issue for deprecation: https://gitlab.com/gitlab-org/gitlab/-/issues/328702
      # Epic for Project topics: https://gitlab.com/groups/gitlab-org/-/epics/552
      expose :tag_list do |project|
        # Avoids an N+1 query: https://github.com/mbleigh/acts-as-taggable-on/issues/91#issuecomment-168273770
        project.topic_names_sorted
      end

      # Duplicate of tag_list above. See the comment for tag_list.
      expose :topics do |project|
        # Avoids an N+1 query: https://github.com/mbleigh/acts-as-taggable-on/issues/91#issuecomment-168273770
        project.topic_names_sorted
      end

      expose :ssh_url_to_repo, :http_url_to_repo, :web_url, :readme_url

      expose :license_url, if: :license do |project|
        license = project.repository.license_blob

        if license
          Gitlab::Routing.url_helpers.project_blob_url(project, File.join(project.default_branch, license.path))
        end
      end

      expose :license, with: 'API::Entities::LicenseBasic', if: :license do |project|
        project.repository.license
      end

      expose :avatar_url do |project, options|
        project.avatar_url(only_path: false)
      end

      expose :forks_count
      expose :star_count
      expose :last_activity_at
      expose :namespace, using: 'API::Entities::NamespaceBasic'
      expose :custom_attributes, using: 'API::Entities::CustomAttribute', if: :with_custom_attributes

      # rubocop: disable CodeReuse/ActiveRecord
      def self.preload_relation(projects_relation, options = {})
        # Preloading tags, should be done with using only `:tags`,
        # as `:tags` are defined as: `has_many :tags, through: :taggings`
        # N+1 is solved then by using `subject.tags.map(&:name)`
        # MR describing the solution: https://gitlab.com/gitlab-org/gitlab-foss/merge_requests/20555
        projects_relation.preload(:project_feature, :route)
                         .preload(:import_state, :tags)
                         .preload(:auto_devops)
                         .preload(namespace: [:route, :owner])
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
