# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  include IgnorableColumns

  belongs_to :namespace
  belongs_to :display_namespace, class_name: 'Namespace', optional: true

  has_many :snapshots, foreign_key: :namespace_id, primary_key: :namespace_id

  validates :namespace, uniqueness: { scope: :display_namespace_id }, presence: true

  scope :ordered_by_name, -> { includes(:namespace).order('"namespaces"."name" ASC') }
  scope :for_display_namespaces, -> (namespaces) { where(display_namespace_id: namespaces) }
  scope :for_namespaces, -> (namespaces) { where(namespace_id: namespaces) }
  scope :for_parent, -> (namespace) { for_namespaces(namespace.self_and_descendants) }

  ignore_column :last_recorded_at, remove_with: '14.2', remove_after: '2021-07-22'

  def latest_snapshot
    snapshots.by_end_time.first
  end
end
