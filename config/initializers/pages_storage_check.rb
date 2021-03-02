# frozen_string_literal: true

# This is to make sure at least one storage strategy for Pages is enabled.

return if ::Feature.enabled?(:pages_update_legacy_storage, default_enabled: true)

pages = Settings.pages

unless pages['local_store']['enabled'] || pages['object_store']['enabled']
  raise "Please enable at least one of the two Pages storage strategy (local_store or object_store) in your config/gitlab.yml - set their 'enabled' attribute to true."
end
