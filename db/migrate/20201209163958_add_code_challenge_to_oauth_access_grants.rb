class AddCodeChallengeToOauthAccessGrants < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column(:oauth_access_grants, :code_challenge, :text, null: true)
    # If `code_challenge_method` is 'plain' the length is at most 128 characters as per the spec
    # https://tools.ietf.org/html/rfc7636#section-4.1
    # Otherwise the max length of base64(SHA256(code_verifier)) is 44 characters
    add_text_limit(:oauth_access_grants, :code_challenge, 128, constraint_name: 'oauth_access_grants_code_challenge')

    add_column(:oauth_access_grants, :code_challenge_method, :text, null: true)
    # Values are either 'plain' or 'S256'
    add_text_limit(:oauth_access_grants, :code_challenge_method, 5, constraint_name: 'oauth_access_grants_code_challenge_method')
  end
end
