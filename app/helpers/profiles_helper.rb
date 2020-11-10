# frozen_string_literal: true

module ProfilesHelper
  def commit_email_select_options(user)
    private_email = user.private_commit_email
    verified_emails = user.verified_emails - [private_email]

    [
      [s_("Profiles|Use a private email - %{email}").html_safe % { email: private_email }, Gitlab::PrivateCommitEmail::TOKEN],
      *verified_emails
    ]
  end

  def selected_commit_email(user)
    user.read_attribute(:commit_email) || user.commit_email
  end

  def attribute_provider_label(attribute)
    user_synced_attributes_metadata = current_user.user_synced_attributes_metadata
    if user_synced_attributes_metadata&.synced?(attribute)
      if user_synced_attributes_metadata.provider
        Gitlab::Auth::OAuth::Provider.label_for(user_synced_attributes_metadata.provider)
      else
        'LDAP'
      end
    end
  end

  def user_profile?
    params[:controller] == 'users'
  end

  def availability_values
    Types::AvailabilityEnum.enum
  end

  def has_custom_status_emoji?(user)
    # the default emoji is set when we update either the emoji field or message field
    # if there is no message and the emoji is "speech_balloon" we are using the default
    user.status && (user.status.message.present? || user.status.emoji != UserStatus::DEFAULT_EMOJI)
  end

  def default_emoji
    UserStatus::DEFAULT_EMOJI
  end
end
