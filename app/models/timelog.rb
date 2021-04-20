# frozen_string_literal: true

class Timelog < ApplicationRecord
  include Importable
  include FromUnion

  validates :time_spent, :user, presence: true
  validate :issuable_id_is_present, unless: :importing?

  belongs_to :issue, touch: true
  belongs_to :merge_request, touch: true
  belongs_to :user
  belongs_to :note

  scope :for_issues_in_group, -> (group) do
    joins(:issue).where(
      'EXISTS (?)',
      Project.select(1).where(namespace: group.self_and_descendants)
        .where('issues.project_id = projects.id')
    )
  end

  scope :in_project, -> (project) do
    issue_timelogs = joins(:issue).where("issues.project_id = ?", project.id)
    merge_request_timelogs = joins(:merge_request).where("merge_requests.target_project_id = ?", project.id)

    from_union([issue_timelogs, merge_request_timelogs])
  end

  scope :between_times, -> (start_time, end_time) do
    where('spent_at BETWEEN ? AND ?', start_time, end_time)
  end

  def issuable
    issue || merge_request
  end

  private

  def issuable_id_is_present
    if issue_id && merge_request_id
      errors.add(:base, _('Only Issue ID or merge request ID is required'))
    elsif issuable.nil?
      errors.add(:base, _('Issue or merge request ID is required'))
    end
  end

  # Rails5 defaults to :touch_later, overwrite for normal touch
  def belongs_to_touch_method
    :touch
  end
end
