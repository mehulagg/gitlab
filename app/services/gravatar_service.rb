# frozen_string_literal: true

class GravatarService
  def execute(email, size = nil, scale = 2, username: nil)
    return unless Gitlab::CurrentSettings.gravatar_enabled?

    identifier = email.presence || username.presence
    return unless identifier

    hash = Digest::MD5.hexdigest(identifier.strip.downcase)
    size = 40 unless size && size > 0
    default_avatar_number = rand(1..80)
    default_avatar_image_path = ActionController::Base.helpers.image_path("default_avatars/avatanuki-#{default_avatar_number}.png")
    default_avatar_url = "#{gitlab_config.base_url}#{default_avatar_image_path}"

    sprintf gravatar_url,
      hash: hash,
      size: size * scale,
      email: ERB::Util.url_encode(email&.strip || ''),
      username: ERB::Util.url_encode(username&.strip || ''),
      default: ERB::Util.url_encode(default_avatar_url)
  end

  def gitlab_config
    Gitlab.config.gitlab
  end

  def gravatar_config
    Gitlab.config.gravatar
  end

  def gravatar_url
    if gitlab_config.https
      gravatar_config.ssl_url
    else
      gravatar_config.plain_url
    end
  end
end
