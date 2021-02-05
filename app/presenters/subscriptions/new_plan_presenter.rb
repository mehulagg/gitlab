# frozen_string_literal: true

module Subscriptions
  class NewPlanPresenter < Gitlab::View::Presenter::Delegated
    presents :plan

    NEW_PLAN_TITLES = {
      silver: 'Premium (Formerly Silver)',
      gold: 'Ultimate (Formerly Ultimate)'
    }.freeze

    def title
      return super unless new_plan_available?

      NEW_PLAN_TITLES[plan_key]
    end

    private

    def plan_key
      name&.to_sym
    end

    def new_plan_available?
      NEW_PLAN_TITLES.has_key?(plan_key)
    end
  end
end
