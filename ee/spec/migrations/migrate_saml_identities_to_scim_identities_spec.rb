# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe MigrateSamlIdentitiesToScimIdentities, :migration do
  let(:group1) { table(:namespaces).create!(name: 'group1', path: 'group1') }
  let(:group2) { table(:namespaces).create!(name: 'group2', path: 'group2') }
  let(:saml_provider1) { table(:saml_providers).create!(enabled: true, group_id: group1.id, certificate_fingerprint: '123abc', sso_url: 'https://sso1.example.com') }
  let(:saml_provider2) { table(:saml_providers).create!(enabled: false, group_id: group2.id, certificate_fingerprint: '123abc', sso_url: 'https://sso2.example.com') }

  let(:users) { table(:users) }
  let(:scim_identities) { table(:scim_identities) }
  let(:identities) { table(:identities) }

  before do
    create_user_and_identity(1, identity_options: { saml_provider_id: saml_provider1.id })
    create_user_and_identity(2, identity_options: { saml_provider_id: saml_provider2.id })
    create_user_and_identity(3, identity_options: { saml_provider_id: nil, provider: 'ldapmain' })
  end

  context 'when a matching saml provider and scim oauth access token exist' do
    before do
      table(:scim_oauth_access_tokens).create!(group_id: group1.id, token_encrypted: '123abc')
      table(:scim_oauth_access_tokens).create!(group_id: group2.id, token_encrypted: '456def')
    end

    it 'migrates all group_saml identities' do
      expect(scim_identities.count).to be_zero

      migrate!

      scim_identity1 = scim_identities.find_by(extern_uid: 'user1')
      scim_identity2 = scim_identities.find_by(extern_uid: 'user2')

      expect(scim_identities.count).to eq(2)

      expect(scim_identity1.extern_uid).to eq('user1')
      expect(scim_identity1.group_id).to eq(group1.id)
      expect(scim_identity1.user_id).to eq(1)
      expect(scim_identity1.active).to eq(true)

      expect(scim_identity2.extern_uid).to eq('user2')
      expect(scim_identity2.group_id).to eq(group2.id)
      expect(scim_identity2.user_id).to eq(2)
      expect(scim_identity2.active).to eq(true)
    end

    it 'does not migrate non-group_saml identities' do
      migrate!

      expect(scim_identity('user3')).to be_nil
    end

    context 'when duplicate scim_identities already exist' do
      before do
        scim_identities.create!(extern_uid: 'user1', group_id: group1.id, user_id: 1)
      end

      it 'migrates missing group_saml identities without conflict' do
        migrate!

        expect(scim_identity('user2')).to be_present
      end
    end
  end

  context 'when a matching scim oauth access token does not exist' do
    it 'does not migrate group_saml identities' do
      expect(scim_identities.count).to be_zero

      migrate!

      expect(scim_identities.count).to be_zero
    end
  end

  def create_user_and_identity(id, user_options: {}, identity_options: {})
    default_user_options = {
      id: id,
      username: "user#{id}",
      email: "user#{id}@example.com",
      projects_limit: 10
    }

    default_identity_options = {
      id: id,
      user_id: id,
      extern_uid: "user#{id}",
      provider: 'group_saml'
    }

    users.create!(default_user_options.merge(user_options))
    identities.create!(default_identity_options.merge(identity_options))
  end

  def scim_identity(extern_uid)
    scim_identities.find_by(extern_uid: extern_uid)
  end
end
