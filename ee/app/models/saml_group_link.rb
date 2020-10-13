# frozen_string_literal: true

class SamlGroupLink < ApplicationRecord
  belongs_to :group

  validates :group, presence: true
  validates :access_level, presence: true, inclusion: { in: Gitlab::Access.all_values }
  validates :group_name, presence: true, uniqueness: { scope: [:group_id] }, length: { maximum: 255 }
end
