# frozen_string_literal: true

# Base class, scoped by project
#
# NOTE: This is part of the migration from BaseService
# to BaseContainerService. See notes at top of
# app/services/base_service.rb for more details.
module Projects
  class BaseProjectService < ::BaseContainerService
    attr_accessor :project

    def initialize(container:, current_user: nil, params: {})
      super

      @project = container
    end

    delegate :repository, to: :project
  end
end
