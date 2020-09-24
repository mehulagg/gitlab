# frozen_string_literal: true

module Vulnerabilities
  class Statistic < ApplicationRecord
    self.table_name = 'vulnerability_statistics'

    belongs_to :project, optional: false

    enum letter_grade: { a: 0, b: 1, c: 2, d: 3, f: 4 }

    validates :total, numericality: { greater_than_or_equal_to: 0 }
    validates :critical, numericality: { greater_than_or_equal_to: 0 }
    validates :high, numericality: { greater_than_or_equal_to: 0 }
    validates :medium, numericality: { greater_than_or_equal_to: 0 }
    validates :low, numericality: { greater_than_or_equal_to: 0 }
    validates :unknown, numericality: { greater_than_or_equal_to: 0 }
    validates :info, numericality: { greater_than_or_equal_to: 0 }

    before_save :assign_letter_grade

    scope :for_project, ->(project) { where(project_id: project) }

    class << self
      # Takes an object which responds to `#[]` method call
      # like an instance of ActiveRecord::Base or a Hash and
      # returns the letter grade value for given object.
      def letter_grade_for(object)
        if object['critical'].to_i > 0
          letter_grades[:f]
        elsif object['high'].to_i > 0 || object['unknown'].to_i > 0
          letter_grades[:d]
        elsif object['medium'].to_i > 0
          letter_grades[:c]
        elsif object['low'].to_i > 0
          letter_grades[:b]
        else
          letter_grades[:a]
        end
      end
    end

    private

    def assign_letter_grade
      self.letter_grade = self.class.letter_grade_for(self)
    end
  end
end
