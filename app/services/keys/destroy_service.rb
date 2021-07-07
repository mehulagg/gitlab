# frozen_string_literal: true

module Keys
  class DestroyService < ::Keys::BaseService
    def execute(key)
      result = key.destroy if destroy_possible?(key)
      audit_destroy(key) if result
    end

    # overridden in EE::Keys::DestroyService
    def destroy_possible?(key)
      true
    end

    # overridden in EE::Keys::DestroyService
    def audit_destroy(key)
    end
  end
end

Keys::DestroyService.prepend_mod_with('Keys::DestroyService')
