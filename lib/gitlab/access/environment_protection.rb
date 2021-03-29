# frozen_string_literal: true

module Gitlab
  module Access
    class EnvironmentProtection
      attr_accesor :user

      def has_access_to?(environment)
        project = environment.project
        protected_environment = project.protected_environments.find_by_name(environment: name)
        protected_environment.nil? || protected_environment.accessible_to?(user)
      end
    end
  end
end
