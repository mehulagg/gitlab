# frozen_string_literal: true

class SamlGroupLink < ApplicationRecord
  belongs_to :group

  enum access_level: ::Gitlab::Access.options_with_owner

  validates :group, :access_level, presence: true
  validates :saml_group_name, presence: true, uniqueness: { scope: [:group_id] }, length: { maximum: 255 }

  scope :by_id_and_group_id, ->(id, group_id) { where(id: id, group_id: group_id) }
end
