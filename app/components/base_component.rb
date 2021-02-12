# frozen_string_literal: true

class BaseComponent < ViewComponent::Base
  delegate_missing_to :helpers
end
