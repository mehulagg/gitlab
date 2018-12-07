# frozen_string_literal: true

class Epic::Metrics < ActiveRecord::Base
  belongs_to :epic

  def record!
    self.save
  end
end
