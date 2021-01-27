# frozen_string_literal: true

class AdminNote < ApplicationRecord
  belongs_to :namespace, inverse_of: :admin_note
  validates_presence_of :namespace
end
