# frozen_string_literal: true

module EE
  module Iterations
    module Cadence
      extend ActiveSupport::Concern

      prepended do
        belongs_to :group
        has_many :iterations, foreign_key: :iterations_cadence_id, inverse_of: :iterations_cadence

        validates :title, presence: true
        validates :start_date, presence: true
        validates :group_id, presence: true
        validates :active, presence: true
        validates :automatic, presence: true
      end
    end
  end
end
