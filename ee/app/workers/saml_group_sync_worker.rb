# frozen_string_literal: true

class SamlGroupSyncWorker
  include ApplicationWorker

  feature_category :authentication_and_authorization
  idempotent!
  weight 2

  def perform(user_id, top_level_group_id, group_link_ids)
    top_level_group = Group.find_by_id(top_level_group_id)
    user = User.find_by_id(user_id)

    return unless top_level_group&.saml_enabled? && user

    group_links = find_group_links(group_link_ids, top_level_group)
    ::Groups::SyncService.new(nil, user, group_links: group_links).execute
  end

  private

  def find_group_links
    allowed_group_ids = top_level_group.self_and_descendants_ids

    SamlGroupLink.by_id_and_group_id(group_link_ids, allowed_group_ids)
  end
end
