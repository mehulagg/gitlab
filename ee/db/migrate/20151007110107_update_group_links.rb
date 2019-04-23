class UpdateGroupLinks < ActiveRecord::Migration[4.2]
  def change
    provider = quote_string(Gitlab::Auth::LDAP::Config.providers.first)
    execute("UPDATE ldap_group_links SET provider = '#{provider}' WHERE provider IS NULL")
  end
end
