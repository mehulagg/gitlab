# frozen_string_literal: true

module CanPickRepositoryStorage
  extend ActiveSupport::Concern

  class_methods do
    def pick_repository_storage
      # We need to ensure application settings are fresh when we pick
      # a repository storage to use.
      Gitlab::CurrentSettings.expire_current_application_settings
      Gitlab::CurrentSettings.pick_repository_storage
    end
  end
end
