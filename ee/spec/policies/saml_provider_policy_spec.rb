# frozen_string_literal: true
require 'spec_helper'

RSpec.describe SamlProviderPolicy do
  let(:group_visibility) { :public }
  let(:group) { create(:group, group_visibility) }
  let(:saml_provider) { create(:saml_provider, group: group) }

  context 'with a user' do
    let(:user) { create(:user) }

    subject { described_class.new(user, saml_provider) }

    it 'allows access to public groups' do
      is_expected.to be_allowed(:sign_in_with_saml_provider)
    end

    it 'allows access to private groups' do
      group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

      is_expected.to be_allowed(:sign_in_with_saml_provider)
    end
  end

  context 'with a token actor' do
    subject { described_class.new(token_actor, saml_provider) }

    context 'valid token' do
      let(:token_actor) { Gitlab::Auth::GroupSaml::TokenActor.new(group.saml_discovery_token) }

      it 'allows access to public groups' do
        is_expected.to be_allowed(:sign_in_with_saml_provider)
      end

      it 'allows access to private groups' do
        group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

        is_expected.to be_allowed(:sign_in_with_saml_provider)
      end
    end

    context 'invalid or missing token' do
      let(:token_actor) { Gitlab::Auth::GroupSaml::TokenActor.new("xyz") }

      it 'allows anonymous access to public groups' do
        is_expected.to be_allowed(:sign_in_with_saml_provider)
      end

      it 'prevents access to private groups' do
        group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

        is_expected.not_to be_allowed(:sign_in_with_saml_provider)
      end
    end
  end

  context 'without a user or actor' do
    subject { described_class.new(nil, saml_provider) }

    it 'allows access to public groups' do
      is_expected.to be_allowed(:sign_in_with_saml_provider)
    end

    it 'prevents access to private groups' do
      group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

      is_expected.not_to be_allowed(:sign_in_with_saml_provider)
    end
  end
end
