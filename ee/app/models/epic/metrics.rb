# frozen_string_literal: true

class Epic::Metrics < NamespaceShard
  belongs_to :epic

  def record!
    self.save
  end
end
