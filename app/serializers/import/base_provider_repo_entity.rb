# frozen_string_literal: true

class ImportBaseProviderRepoEntity < Grape::Entity
  expose :id
  expose :full_name
  expose :owner_name
  expose :sanitized_name
  expose :provider_link
end
