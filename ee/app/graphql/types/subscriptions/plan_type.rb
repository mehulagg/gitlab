# frozen_string_literal: true

module Types
  module Subscriptions
    class PlanType < BaseObject
      field :id, ID, null: true
      field :name, String, null: true
      field :free, Boolean, null: true
      field :price_per_month, Float, null: true
      field :features, String, null: true
      field :about_page_href, String, null: true
      field :code, String, null: true
      field :price_per_year, Float, null: true
      field :active, Boolean, null: true
      field :deprecated, Boolean, null: true
      field :hide_deprecated_card, Boolean, null: true
    end
  end
end
