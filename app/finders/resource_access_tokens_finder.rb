# frozen_string_literal: true

class ResourceAccessTokensFinder < ::PersonalAccessTokensFinder # rubocop:disable Gitlab/NamespacedClass
  def applicable_tokens
    PersonalAccessToken.for_users(params[:project].bots).eager_load_users_and_project_memberships
  end
end
