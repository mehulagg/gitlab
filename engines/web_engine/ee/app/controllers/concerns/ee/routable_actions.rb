# frozen_string_literal: true

module EE
  module RoutableActions
    extend ::Gitlab::Utils::Override

    override :not_found_actions
    def not_found_actions
      super + [SsoEnforcementRedirect::ControllerActions.on_routable_not_found]
    end
  end
end
