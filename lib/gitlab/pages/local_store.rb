# frozen_string_literal: true

module Gitlab
  module Pages
    class LocalStore < ::SimpleDelegator
      def enabled
        return false unless Feature.enabled?(:pages_update_legacy_storage, default_enabled: true)

        super
      end
    end
  end
end
