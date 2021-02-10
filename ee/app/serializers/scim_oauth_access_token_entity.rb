# frozen_string_literal: true

class ScimOauthAccessTokenEntity < Grape::Entity
  include ::API::Helpers::RelatedResourcesHelpers

  SCIM_PATH = '/api/scim/v2/groups'

  expose :scim_api_url do |scim|
    expose_url("#{SCIM_PATH}/#{scim.group.full_path}")
  end

  expose :token, as: :scim_token
end
