# frozen_string_literal: true

class EmailReceiverWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :issue_tracking
  urgency :high
  weight 2

  def perform(raw)
    return unless Gitlab::IncomingEmail.enabled?

    @raw = raw

    receiver.execute
    log_success
  rescue Gitlab::Email::ProcessingError => e
    log_error(e)
    handle_failure(e)
  rescue StandardError => e
    log_error(e)
    # If there is an internal error, allow job to retry
    raise
  end

  private

  def log_success
    payload = receiver.mail_metadata.merge({ message: "Successfully processed message" })
    Sidekiq.logger.info(payload)
  end

  def log_error(error)
    payload =
      case error
      # Unparsable e-mails don't have metadata we can use
      when Gitlab::Email::EmailUnparsableError, Gitlab::Email::EmptyEmailError
        {}
      else
        mail_metadata
      end

    # We don't need the backtrace and more details if the e-mail couldn't be processed
    if error.is_a?(Gitlab::Email::ProcessingError)
      payload['exception.class'] = error.class.name
    else
      Gitlab::ExceptionLogFormatter.format!(error, payload)
      Gitlab::ErrorTracking.track_exception(error)
    end

    Sidekiq.logger.error(payload)
  end

  def receiver
    @receiver ||= Gitlab::Email::Receiver.new(@raw)
  end

  def mail_metadata
    receiver.mail_metadata
  rescue StandardError => e
    # We should never get here as long as we check EmailUnparsableError, but
    # let's be defensive in case we did something wrong.
    Gitlab::ErrorTracking.track_exception(e)
    {}
  end

  def handle_failure(error)
    return unless @raw.present?

    can_retry = false
    reason =
      case error
      when Gitlab::Email::UnknownIncomingEmail
        s_("EmailError|We couldn't figure out what the email is for. Please create your issue or comment through the web interface.")
      when Gitlab::Email::SentNotificationNotFoundError
        s_("EmailError|We couldn't figure out what the email is in reply to. Please create your comment through the web interface.")
      when Gitlab::Email::ProjectNotFound
        s_("EmailError|We couldn't find the project. Please check if there's any typo.")
      when Gitlab::Email::EmptyEmailError
        can_retry = true
        s_("EmailError|It appears that the email is blank. Make sure your reply is at the top of the email, we can't process inline replies.")
      when Gitlab::Email::UserNotFoundError
        s_("EmailError|We couldn't figure out what user corresponds to the email. Please create your comment through the web interface.")
      when Gitlab::Email::UserBlockedError
        s_("EmailError|Your account has been blocked. If you believe this is in error, contact a staff member.")
      when Gitlab::Email::UserNotAuthorizedError
        s_("EmailError|You are not allowed to perform this action. If you believe this is in error, contact a staff member.")
      when Gitlab::Email::NoteableNotFoundError
        s_("EmailError|The thread you are replying to no longer exists, perhaps it was deleted? If you believe this is in error, contact a staff member.")
      when Gitlab::Email::InvalidAttachment
        error.message
      when Gitlab::Email::InvalidRecordError
        can_retry = true
        error.message
      end

    if reason
      EmailRejectionMailer.rejection(reason, @raw, can_retry).deliver_later
    end
  end
end
