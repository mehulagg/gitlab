# frozen_string_literal: true

# == Subscribable concern
#
# Users can subscribe to these models.
#
# Used by Issue, MergeRequest, Label
#

module Subscribable
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, dependent: :destroy, as: :subscribable # rubocop:disable Cop/ActiveRecordDependent
  end

  def subscribed?(user, project = nil)
    return false unless user

    if (subscription = subscriptions.find_by(user: user, project: project))
      subscription.subscribed
    else
      subscribed_without_subscriptions?(user, project)
    end
  end

  def lazy_subscribed?(user, project = nil)
    return false unless user

    if (subscription = lazy_subscription(user, project)&.itself)
      subscription.subscribed
    else
      subscribed_without_subscriptions?(user, project)
    end
  end

  def lazy_subscription(user, project = nil)
    return unless user

    # handle project and group labels as well as issuable subscriptions
    subscribable_type = self.class.ancestors.include?(Label) ? 'Label' : self.class.name
    BatchLoader.for(id: id, subscribable_type: subscribable_type).batch do |items, loader|
      ids = items.map { |i| i[:id] }
      subscribable_types = items.map { |i| i[:subscribable_type] }.uniq
      subscriptions = Subscription.where(subscribable_id: ids, subscribable_type: subscribable_types, project: project, user: user)

      subscriptions.each do |subscription|
        loader.call({ id: subscription.subscribable_id, subscribable_type: subscription.subscribable_type }, subscription)
      end
    end
  end

  # Override this method to define custom logic to consider a subscribable as
  # subscribed without an explicit subscription record.
  def subscribed_without_subscriptions?(user, project)
    false
  end

  def subscribers(project)
    relation = subscriptions_available(project)
                 .where(subscribed: true)
                 .select(:user_id)

    User.where(id: relation)
  end

  def toggle_subscription(user, project = nil)
    unsubscribe_from_other_levels(user, project)

    find_or_initialize_subscription(user, project)
      .update(subscribed: !subscribed?(user, project))
  end

  def subscribe(user, project = nil)
    unsubscribe_from_other_levels(user, project)

    find_or_initialize_subscription(user, project)
      .update(subscribed: true)
  end

  def unsubscribe(user, project = nil)
    unsubscribe_from_other_levels(user, project)

    find_or_initialize_subscription(user, project)
      .update(subscribed: false)
  end

  def set_subscription(user, desired_state, project = nil)
    if desired_state
      subscribe(user, project)
    else
      unsubscribe(user, project)
    end
  end

  private

  def unsubscribe_from_other_levels(user, project)
    other_subscriptions = subscriptions.where(user: user)

    other_subscriptions =
      if project.blank?
        other_subscriptions.where.not(project: nil)
      else
        other_subscriptions.where(project: nil)
      end

    other_subscriptions.update_all(subscribed: false)
  end

  def find_or_initialize_subscription(user, project)
    subscriptions
      .find_or_initialize_by(user_id: user.id, project_id: project.try(:id))
  end

  def subscriptions_available(project)
    t = Subscription.arel_table

    subscriptions
      .where(t[:project_id].eq(nil).or(t[:project_id].eq(project.try(:id))))
  end
end
