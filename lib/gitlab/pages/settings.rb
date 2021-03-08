# frozen_string_literal: true

module Gitlab
  module Pages
    class Settings < ::SimpleDelegator
      DiskAccessDenied = Class.new(StandardError)

      def path
        if disk_access_denied?
          raise DiskAccessDenied
        end

        super
      end

      def local_store
        @local_store ||= ::Gitlab::Pages::LocalStore.new(super)
      end

      private

      def disk_access_denied?
        return true unless ::Settings.pages.local_store.enabled

        ::Gitlab::Runtime.web_server? && !::Gitlab::Runtime.test_suite?
      end
    end
  end
end
