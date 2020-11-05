# frozen_string_literal: true

class GroupSamlGroupSyncWorker
  include ApplicationWorker

  feature_category :authentication_and_authorization
  idempotent!

  def perform(user_id, top_level_group_id, group_link_ids)
    top_level_group = Group.find_by_id(top_level_group_id)
    user = User.find_by_id(user_id)

    return unless user && feature_available?(top_level_group)

    group_links = find_group_links(group_link_ids, top_level_group)

    Groups::SyncService.new(nil, user, group_links: group_links).execute
  end

  private

  def feature_available?(group)
    group && group.saml_group_sync_available?
  end

  def find_group_links(group_link_ids, top_level_group)
    SamlGroupLink.by_id_and_group_id(group_link_ids, top_level_group.self_and_descendants.select(:id))
  end
end
