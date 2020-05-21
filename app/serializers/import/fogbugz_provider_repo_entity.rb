# frozen_string_literal: true

class ImportFogbugzProviderRepoEntity < ImportBaseProviderRepoEntity
  include ImportHelper

  expose :id
  expose :full_name, override: true do |repo|
    repo.name
  end

  expose :owner_name, override: true do
    ''
  end

  expose :sanitized_name, override: true do |repo|
    repo.safe_name
  end

  expose :provider_link, override: true do |repo, options|
    provider_project_link_url(options[:provider_url], repo.path)
  end
end
