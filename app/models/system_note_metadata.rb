class SystemNoteMetadata < ApplicationRecord
  # These notes's action text might contain a reference that is external.
  # We should always force a deep validation upon references that are found
  # in this note type.
  # Other notes can always be safely shown as all its references are
  # in the same project (i.e. with the same permissions)
  TYPES_WITH_CROSS_REFERENCES = %w[
    commit cross_reference
    close duplicate
    relate unrelate
  ].freeze

  ICON_TYPES = %w[
    commit description merge confidential visible label assignee cross_reference
    title time_tracking branch milestone discussion task moved
    opened closed merged duplicate locked unlocked
    outdated
    approved unapproved relate unrelate
    epic_issue_added issue_added_to_epic epic_issue_removed issue_removed_from_epic
    epic_issue_moved issue_changed_epic
  ].freeze

  validates :note, presence: true
  validates :action, inclusion: ICON_TYPES, allow_nil: true

  belongs_to :note
end
