# frozen_string_literal: true

class ProviderRepoEntity < Grape::Entity
  include ImportHelper

  expose :id
  # expose :full_name
  expose :owner_name do |provider_repo, options|
    owner_name(provider_repo, options[:provider])
  end

  expose :sanitized_name do |provider_repo, options|
    if options[:provider] == :fogbugz
      sanitize_project_name(provider_repo.safe_name)
    else
      sanitize_project_name(provider_repo[:name])
    end
  end

  expose :provider_link do |provider_repo, options|
    if options[:provider] == :fogbugz
      provider_project_link_url(options[:provider_url], provider_repo.name)
    else
      provider_project_link_url(options[:provider_url], provider_repo[:name])
    end
  end

  private

  def owner_name(provider_repo, provider)
    provider_repo.dig(:owner, :login) if provider == :github
  end
end
