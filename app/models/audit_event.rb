# frozen_string_literal: true

class AuditEvent < ApplicationRecord
  include CreatedAtFilterable

  serialize :details, Hash # rubocop:disable Cop/ActiveRecordSerialize

  belongs_to :user, foreign_key: :author_id

  validates :author_id, presence: true
  validates :entity_id, presence: true
  validates :entity_type, presence: true

  scope :by_entity_type, -> (entity_type) { where(entity_type: entity_type) }
  scope :by_entity_id, -> (entity_id) { where(entity_id: entity_id) }

  after_initialize :initialize_details

  def self.order_by(method)
    case method.to_s
    when 'created_asc'
      order(id: :asc)
    else
      order(id: :desc)
    end
  end

  def initialize_details
    self.details = {} if details.nil?
  end

  def author_name
    self.user.name
  end

  def formatted_details
    details.merge(details.slice(:from, :to).transform_values(&:to_s))
  end
end

AuditEvent.prepend_if_ee('EE::AuditEvent')
