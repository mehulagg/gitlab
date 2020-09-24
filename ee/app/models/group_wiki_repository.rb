# frozen_string_literal: true

class GroupWikiRepository < ApplicationRecord
  include Shardable

  belongs_to :group

  validates :group, :disk_path, presence: true, uniqueness: true
end
