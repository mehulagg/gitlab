# frozen_string_literal: true

module Licenses
  class DestroyService < ::Licenses::BaseService
    extend ::Gitlab::Utils::Override

    DestroyCloudLicenseError = Class.new(StandardError)

    override :execute
    def execute
      raise ActiveRecord::RecordNotFound unless license
      raise Gitlab::Access::AccessDeniedError unless can?(user, :destroy_licenses)
      raise DestroyCloudLicenseError.new(_('Cloud licenses can not be removed.')) if license.cloud?

      license.destroy
    end
  end
end
