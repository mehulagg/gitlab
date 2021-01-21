# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  include IgnorableColumns

  belongs_to :namespace
  has_many :snapshots, inverse_of: :segment
  has_one :latest_snapshot, -> { order(recorded_at: :desc) }, inverse_of: :segment, class_name: 'Snapshot'

  ignore_column :name, remove_with: '13.11', remove_after: '2021-03-22'

  validates :namespace, uniqueness: true, presence: true

  scope :ordered_by_name, -> { includes(:namespace).order('"namespaces"."name" ASC') }
end
