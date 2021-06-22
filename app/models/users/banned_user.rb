# frozen_string_literal: true

class BannedUser < ApplicationRecord
  belongs_to :user
end
