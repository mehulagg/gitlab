# frozen_string_literal: true

class ExperimentSubject < ApplicationRecord
  include ::Gitlab::Experimentation::GroupTypes

  belongs_to :experiment, inverse_of: :experiment_subjects
  belongs_to :user
  belongs_to :group
  belongs_to :project

  validates :experiment, presence: true
  validates :variant, presence: true
  validate :must_have_one_subject_present

  enum variant: { GROUP_CONTROL => 0, GROUP_EXPERIMENTAL => 1 }

  class << self
    def find_by_subject(subject)
      find_by(parameterized_subject(subject))
    end

    def find_or_initialize_by_subject(subject)
      find_or_initialize_by(parameterized_subject(subject))
    end

    private

    def parameterized_subject(subject)
      { subject.class.model_name.param_key => subject }
    end
  end

  private

  def must_have_one_subject_present
    if non_nil_subjects.length != 1
      errors.add(:base, s_("ExperimentSubject|Must have exactly one of User, Group, or Project."))
    end
  end

  def non_nil_subjects
    @non_nil_subjects ||= [user, group, project].reject(&:blank?)
  end
end
