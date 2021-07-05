class BranchMirror < ApplicationRecord
  belongs_to :project

  validates :from_branch, presence: true
  validates :to_branch, presence: true
end
