# frozen_string_literal: true

class BaseComponent < ViewComponent::Base
  # To make converting partials to components easier,
  # we delegate all missing methods to the helpers,
  # where they probably are.
  delegate_missing_to :helpers
end
