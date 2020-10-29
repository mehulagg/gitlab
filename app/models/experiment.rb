# frozen_string_literal: true

class Experiment < ApplicationRecord
  has_many :experiment_users

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  def self.add_user(name, group_type, user)
    return unless experiment = find_or_create_by(name: name)

    experiment.record_user_and_group(user, group_type)
  end

  def record_user_and_group(user, group_type)
    if experiment_users.where(user: user).exists?
      experiment_users.find_by(user: user).update(group_type: group_type)
    else
      experiment_users.create(user: user, group_type: group_type)
    end
  end
end
