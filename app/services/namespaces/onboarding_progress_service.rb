# frozen_string_literal: true

module Namespaces
  class OnboardingProgressService
    def initialize(namespace)
      @namespace = namespace&.root_ancestor
    end

    def execute(action:)
      return unless @namespace

      NamespaceOnboardingAction.create_action(@namespace, action)
    end
  end
end
