# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  include IgnorableColumns

  belongs_to :namespace
  belongs_to :display_namespace, class_name: 'Namespace', optional: true

  has_many :snapshots, inverse_of: :segment
  has_one :latest_snapshot, -> { order(recorded_at: :desc) }, inverse_of: :segment, class_name: 'Snapshot'

  ignore_column :name, remove_with: '14.0', remove_after: '2021-05-22'

  validates :namespace, uniqueness: true, presence: true

  scope :ordered_by_name, -> { includes(:namespace).order('"namespaces"."name" ASC') }
  scope :for_namespaces, -> (namespaces) { where(namespace_id: namespaces) }
  scope :for_parent, -> (namespace) { for_namespaces(namespace.self_and_descendants) }

  # Remove in %14.0 with https://gitlab.com/gitlab-org/gitlab/-/issues/329521
  before_validation -> { self.display_namespace = namespace }
end
