# frozen_string_literal: true

class Import::BitbucketProviderRepoEntity < Import::BaseProviderRepoEntity
  include ImportHelper

  expose :id
  expose :full_name
  expose :owner_name, override: true do |repo|
    repo.owner
  end

  expose :sanitized_name, override: true do |repo|
    repo.safe_name
  end

  expose :provider_link, override: true do |repo, options|
    provider_project_link_url(options[:provider_url], repo.clone_url)
  end
end
