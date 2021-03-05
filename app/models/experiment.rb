# frozen_string_literal: true

class Experiment < ApplicationRecord
  has_many :experiment_users
  has_many :experiment_subjects, inverse_of: :experiment

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  def self.add_user(name, group_type, user, context = {})
    find_or_create_by!(name: name).record_user_and_group(user, group_type, context)
  end

  def self.add_group(name, variant:, group:)
    find_or_create_by!(name: name).record_group_and_variant!(group, variant)
  end

  def self.record_conversion_event(name, user, context = {})
    find_or_create_by!(name: name).record_conversion_event_for_user(user, context)
  end

  # Create or update the recorded experiment_user row for the user in this experiment.
  def record_user_and_group(user, group_type, context = {})
    experiment_user = experiment_users.find_or_initialize_by(user: user)
    experiment_user.update!(group_type: group_type, context: merged_context(experiment_user, context))
  end

  def record_conversion_event_for_user(user, context = {})
    experiment_user = experiment_users.find_by(user: user)
    return unless experiment_user

    experiment_user.touch(:converted_at) if experiment_user.converted_at.nil?
    experiment_user.update!(context: merged_context(experiment_user, context))
  end

  def record_group_and_variant!(group, variant)
    experiment_subjects.find_or_initialize_by(group: group).update!(variant: variant)
  end

  private

  def merged_context(experiment_user, new_context)
    experiment_user.context.deep_merge(new_context.deep_stringify_keys)
  end
end
