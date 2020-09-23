# frozen_string_literal: true

module EE::Projects::UpdatePagesService
  extend ::Gitlab::Utils::Override

  override :max_size_from_settings
  def max_size_from_settings
    return super unless License.feature_available?(:pages_size_limit)

    project.closest_setting(:max_pages_size).megabytes
  end
end
