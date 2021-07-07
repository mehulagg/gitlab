# frozen_string_literal: true

class GroupBadge < Badge
  belongs_to :group, touch: true

  validates :group, presence: true
end
