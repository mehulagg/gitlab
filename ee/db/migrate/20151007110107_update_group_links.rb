# rubocop:disable Rails/ReversibleMigration
class UpdateGroupLinks < ActiveRecord::Migration
  def change
    provider = quote_string(Gitlab::LDAP::Config.providers.first)
    execute("UPDATE ldap_group_links SET provider = '#{provider}' WHERE provider IS NULL")
  end
end
