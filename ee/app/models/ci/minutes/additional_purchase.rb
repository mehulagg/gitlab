# frozen_string_literal: true

module Ci
  module Minutes
    class AdditionalPurchase < ApplicationRecord
      self.table_name = 'ci_minutes_additional_purchases'

      belongs_to :namespace

      validates :expires_at, :namespace, :number_of_minutes, :purchase_id, presence: true
    end
  end
end
