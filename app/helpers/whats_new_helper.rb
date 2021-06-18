# frozen_string_literal: true

module WhatsNewHelper
  def whats_new_most_recent_release_items_count
    ReleaseHighlight.most_recent_item_count
  end

  def whats_new_version_digest
    ReleaseHighlight.most_recent_version_digest
  end

  def display_whats_new?
    (Gitlab.dev_env_org_or_com? || user_signed_in?) &&
    !Gitlab::CurrentSettings.current_application_settings.whats_new_variant_disabled?
  end

  def whats_new_variants
    ApplicationSetting.whats_new_variants
  end

  def whats_new_variants_label(variant)
    case variant
    when 'all_tiers'
      _("All tiers")
    when 'current_tier'
      _("Current tier only")
    when 'disabled'
      _("Inactive")
    end
  end

  def whats_new_variants_description(variant)
    case variant
    when 'all_tiers'
      _("New features from all tiers are included.")
    when 'current_tier'
      _("Only new features in your current subscription tier are .")
    when 'disabled'
      _("What's new is inactive and cannot be viewed.")
    end
  end
end
