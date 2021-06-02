# frozen_string_literal: true

module Packages
  class DestroyService < BaseContainerService
    alias_method :package, :container

    def execute
      if package.destroy!
        package.sync_maven_metadata(current_user)
      end
    end
  end
end
