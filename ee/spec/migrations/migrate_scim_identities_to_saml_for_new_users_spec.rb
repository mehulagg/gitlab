# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200506154421_migrate_scim_identities_to_saml_for_new_users.rb')

describe MigrateScimIdentitiesToSamlForNewUsers, :migration do
  let(:group1) { table(:namespaces).create!(name: 'group1', path: 'group1') }
  let(:group2) { table(:namespaces).create!(name: 'group2', path: 'group2') }
  let(:saml_provider1) { table(:saml_providers).create!(enabled: true, group_id: group1.id, certificate_fingerprint: '123abc', sso_url: 'https://sso1.example.com') }
  let(:saml_provider2) { table(:saml_providers).create!(enabled: true, group_id: group2.id, certificate_fingerprint: '123abc', sso_url: 'https://sso2.example.com') }

  let(:users) { table(:users) }
  let(:scim_identities) { table(:scim_identities) }
  let(:identities) { table(:identities) }

  before do
    saml_provider1
    saml_provider2

    create_user_and_scim_identity(1, scim_identity_options: { group_id: group1.id })
    create_user_and_scim_identity(2, scim_identity_options: { group_id: group2.id })
    create_user_and_both_identities(
      10,
      scim_identity_options: { group_id: group1.id },
      saml_identity_options: { saml_provider_id: saml_provider1.id }
    )
  end

  context 'when a user and scim_identity were created at the same time' do
    it 'creates group SAML identities' do
      migrate!

      saml_identity1 = identities.find_by(extern_uid: 'user1')
      saml_identity2 = identities.find_by(extern_uid: 'user2')

      expect(saml_identity1.provider).to eq('group_saml')
      expect(saml_identity1.user_id).to eq(1)
      expect(saml_identity1.saml_provider_id).to eq(saml_provider1.id)

      expect(saml_identity2.provider).to eq('group_saml')
      expect(saml_identity2.user_id).to eq(2)
      expect(saml_identity2.saml_provider_id).to eq(saml_provider2.id)
    end

    it 'does not create extra identities' do
      expect { migrate! }.to change { identities.count }.by(2)
    end
  end

  context 'when a user and scim_identity were created at different times' do
    it 'does not create an identity' do
      create_user_and_scim_identity(20, scim_identity_options: { group_id: group1.id, created_at: 1.hour.ago })

      migrate!

      saml_identity = identities.find_by(extern_uid: 'user20')

      expect(saml_identity).to be_nil
    end
  end

  def create_user_and_scim_identity(id, scim_identity_options: {})
    default_user_options = {
      id: id,
      username: "user#{id}",
      email: "user#{id}@example.com",
      projects_limit: 10
    }

    default_identity_options = {
      id: id,
      user_id: id,
      extern_uid: "user#{id}"
    }

    users.create!(default_user_options)
    scim_identities.create!(default_identity_options.merge(scim_identity_options))
  end

  def create_user_and_both_identities(id, scim_identity_options: {}, saml_identity_options: {})
    default_identity_options = {
      id: id,
      user_id: id,
      extern_uid: "user#{id}",
      provider: 'group_saml'
    }

    create_user_and_scim_identity(id, scim_identity_options: scim_identity_options)
    identities.create!(default_identity_options.merge(saml_identity_options))
  end
end
