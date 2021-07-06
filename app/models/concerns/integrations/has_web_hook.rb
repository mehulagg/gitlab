# frozen_string_literal: true

module Integrations
  module HasWebHook
    extend ActiveSupport::Concern

    included do
      after_save :compose_web_hook, if: :activated?
    end

    def compose_web_hook
      hook = service_hook || build_service_hook
      yield hook if block_given?
      hook.save!
    end
  end
end
