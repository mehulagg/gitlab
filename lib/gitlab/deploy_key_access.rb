# frozen_string_literal: true

module Gitlab
  class DeployKeyAccess < UserAccess
    def initialize(deploy_key, container: nil, push_ability: :push_code)
      @deploy_key = deploy_key
      @user = deploy_key.user
      @container = container
      @push_ability = push_ability
    end

    private

    attr_reader :deploy_key

    def protected_tag_accessible_to?(ref, action:)
      assert_project!

      true
    end

    def can_collaborate?(ref)
      assert_project!

      project_has_active_user_keys?
    end

    def project_has_active_user_keys?
      user.can?(:read_project, project) && DeployKey.with_write_access_for_project(project).id_in(deploy_key.id).exists?
    end
  end
end
