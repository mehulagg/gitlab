# frozen_string_literal: true

class SavedReply < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
end
