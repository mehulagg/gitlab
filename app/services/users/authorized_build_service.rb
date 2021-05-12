# frozen_string_literal: true

module Users
  class AuthorizedBuildService < BuildService
    private

    def validate_access!
      true
    end

    def signup_params
      super + [:skip_confirmation]
    end
  end
end
