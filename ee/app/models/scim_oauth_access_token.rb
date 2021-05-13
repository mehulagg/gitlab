# frozen_string_literal: true

class ScimOauthAccessToken < NamespaceShard
  include TokenAuthenticatable

  belongs_to :group

  add_authentication_token_field :token, encrypted: :required

  validates :group, presence: true
  before_save :ensure_token

  def self.token_matches_for_group?(token, group)
    # Necessary to call `TokenAuthenticatableStrategies::Encrypted.find_token_authenticatable`
    token = find_by_token(token)

    token && (token.group_id == group.id)
  end

  def as_entity_json
    ScimOauthAccessTokenEntity.new(self).as_json
  end
end
