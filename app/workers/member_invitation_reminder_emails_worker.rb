# frozen_string_literal: true

class MemberInvitationReminderEmailsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :subgroups
  urgency :low

  def perform
    return unless Gitlab::Experimentation.enabled?(:invitation_reminders)

    GroupMember.not_accepted_or_expired_recent_invitations.find_in_batches do |invitations|
      invitations.each do |invitation|
        Members::InvitationReminderEmailService.new(invitation).execute
      end
    end
  end
end
