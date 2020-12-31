# frozen_string_literal: true

module Namespaces
  class InProductMarketingEmailsService
    attr_reader :track, :interval, :sent_email_user_ids

    TRACKS = [:create, :verify, :trial, :team].freeze
    INTERVALS = [1, 5, 10].freeze

    def initialize(track, interval)
      @track = track
      @interval = interval
      @sent_email_user_ids = []
    end

    def execute
      groups_for_track.each_batch do |groups|
        groups.each do |group|
          users_for_group(group).each do |user|
            send_email(user) if can_perform_action?(user)
          end
        end
      end
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def groups_for_track
      scope = Group.distinct.top_most.with_users
      range = (interval + 1).days.ago.beginning_of_day..(interval + 1).days.ago.end_of_day

      case track
      when :create
        scope.where(created_at: range).incompleted_actions([:git_write, :merge_request_created])
      when :verify
        scope.completed_action_within_range(:git_write, range).where.not(namespace_onboarding_actions: { action: :git_write })
      end
    end

    def users_for_group(group)
      group.users.where(email_opted_in: true).where.not(id: sent_email_user_ids)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def can_perform_action?(user)
      case track
      when :create
        user.can?
      end
    end

    def send_email(user)
      sent_email_user_ids << user.id
    end
  end
end
