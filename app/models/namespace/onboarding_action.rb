# frozen_string_literal: true

module Namespace
  class OnboardingAction < ApplicationRecord
    belongs_to :namespace, optional: false
  end
end
