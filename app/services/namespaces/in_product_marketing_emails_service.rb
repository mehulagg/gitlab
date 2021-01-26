# frozen_string_literal: true

module Namespaces
  class InProductMarketingEmailsService
    include Gitlab::Experimentation::GroupTypes

    attr_reader :track, :interval, :sent_email_user_ids

    INTERVAL_DAYS = [1, 5, 10].freeze
    TRACKS = {
      create: :git_write,
      verify: :pipeline_created,
      trial: :trial_started,
      team: :user_added
    }.freeze

    def initialize(track, interval)
      @track = track
      @interval = interval
      @sent_email_user_ids = []
    end

    def execute
      groups_for_track.each_batch do |groups|
        groups.each do |group|
          experiment_enabled_for_group = experiment_enabled_for_group?(group)
          experiment_add_group(group, experiment_enabled_for_group)
          next unless experiment_enabled_for_group

          users_for_group(group).each do |user|
            send_email(user, group) if can_perform_action?(user, group)
          end
        end
      end
    end

    private

    def experiment_enabled_for_group?(group)
      Gitlab::Experimentation.in_experiment_group?(:in_product_marketing_emails, subject: group)
    end

    def experiment_add_group(group, experiment_enabled_for_group)
      variant = experiment_enabled_for_group ? GROUP_EXPERIMENTAL : GROUP_CONTROL
      Experiment.add_group(:in_product_marketing_emails, variant, group)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def groups_for_track
      onboarding_progress_scope = OnboardingProgress
        .latest_completed_action_in_range(completed_actions, range)
        .incomplete_actions(incomplete_action)

      Group.joins(:onboarding_progress).merge(onboarding_progress_scope)
    end

    def users_for_group(group)
      group.users.where(email_opted_in: true)
        .where.not(id: sent_email_user_ids)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def can_perform_action?(user, group)
      case track
      when :create
        user.can?(:create_projects, group)
      when :verify
        user.can?(:create_projects, group)
      when :trial
        user.can?(:start_trial, group)
      when :team
        user.can?(:admin_group_member, group)
      end
    end

    def send_email(user, group)
      NotificationService.new.in_product_marketing(user, group, track, series)
      sent_email_user_ids << user.id
    end

    def completed_actions
      index = TRACKS.keys.index(track)
      index == 0 ? [:created] : TRACKS.values[0..index - 1]
    end

    def range
      (interval + 1).days.ago.beginning_of_day..(interval + 1).days.ago.end_of_day
    end

    def incomplete_action
      TRACKS[track]
    end

    def series
      INTERVAL_DAYS.index(interval)
    end
  end
end
