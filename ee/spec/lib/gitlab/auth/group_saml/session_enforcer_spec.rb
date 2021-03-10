# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::SessionEnforcer do
  describe '#access_restricted' do
    let(:saml_provider) { create(:saml_provider, enforced_sso: true) }
    let(:identity) { create(:group_saml_identity, saml_provider: saml_provider) }
    let(:root_group) { saml_provider.group }
    let(:user) { identity.user }

    subject { described_class.new(user, group).access_restricted? }

    context 'with an active session', :clean_gitlab_redis_shared_state do
      let(:session_id) { '42' }
      let(:stored_session) do
        { 'active_group_sso_sign_ins' => { saml_provider.id => 5.minutes.ago } }
      end

      before do
        Gitlab::Redis::SharedState.with do |redis|
          redis.set("session:gitlab:#{session_id}", Marshal.dump(stored_session))
          redis.sadd("session:lookup:user:gitlab:#{user.id}", [session_id])
        end
      end

      it { is_expected.to be_truthy }
    end

    context 'without any session' do
      it { is_expected.to be_falsey }
    end
  end
end
