# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsersFinder do
  describe '#execute' do
    include_context 'UsersFinder#execute filter by project context'

    context 'with a normal user' do
      context 'with LDAP users' do
        let!(:ldap_user) { create(:omniauth_user, provider: 'ldap') }

        it 'returns ldap users by default' do
          users = described_class.new(normal_user).execute

          expect(users).to contain_exactly(normal_user, blocked_user, omniauth_user, external_user, ldap_user, internal_user, admin_user)
        end

        it 'returns only non-ldap users with skip_ldap: true' do
          users = described_class.new(normal_user, skip_ldap: true).execute

          expect(users).to contain_exactly(normal_user, blocked_user, omniauth_user, external_user, internal_user, admin_user)
        end
      end
    end
  end
end
