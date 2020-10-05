# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupSamlIdentityFinder do
  include Gitlab::Routing

  let(:user) { create(:user) }
  let!(:identity) { create(:group_saml_identity, user: user) }
  let(:saml_provider) { identity.saml_provider }
  let(:group) { saml_provider.group }

  subject { described_class.new(user: user) }

  describe ".find_by_group_and_uid" do
    it "finds identity matching user and group" do
      expect(described_class.find_by_group_and_uid(group: group, uid: identity.extern_uid)).to eq(identity)
    end

    it "returns nil when no saml_provider exists" do
      group.saml_provider.destroy!

      expect(described_class.find_by_group_and_uid(group: group, uid: identity.extern_uid)).to eq(nil)
    end
  end

  describe '.not_managed_identities' do
    subject { described_class.not_managed_identities(group: group) }

    let!(:group_managed_identity) do
      create(:group_saml_identity, saml_provider: saml_provider, user: create(:user, managing_group: group))
    end

    let!(:different_group_managed_identity) do
      create(:group_saml_identity, saml_provider: saml_provider, user: create(:user, :group_managed))
    end

    it 'returns all identities of users not managed by given group' do
      expect(subject).to match_array([identity, different_group_managed_identity])
    end
  end

  describe "#find_linked" do
    it "finds identity matching user and group" do
      expect(subject.find_linked(group: group)).to eq(identity)
    end

    it "returns nil when no saml_provider exists" do
      group.saml_provider.destroy!

      expect(subject.find_linked(group: group)).to eq(nil)
    end

    it "returns nil when group is nil" do
      expect(subject.find_linked(group: nil)).to eq(nil)
    end
  end

  describe "#all" do
    it "finds Group SAML identities for a user" do
      expect(subject.all.first).to eq(identity)
    end

    it "avoids N+1 on access to provider and group path" do
      identity = subject.all.first

      expect { group_path(identity.saml_provider.group) }.not_to exceed_query_limit(0)
    end
  end
end
