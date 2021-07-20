# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::LdapSyncHelper do
  let_it_be(:group) { build(:group) }

  describe '#ldap_sync_now_button_data' do
    sync_group_ldap_path = '/groups/foo-bar/-/ldap/sync'

    before do
      allow(helper).to receive(:sync_group_ldap_path).with(group).and_return(sync_group_ldap_path)
    end

    subject { helper.ldap_sync_now_button_data(group) }

    it 'sets `path` key correctly' do
      expect(subject[:path]).to eq(sync_group_ldap_path)
    end

    it 'sets `modal_attributes` key to valid json' do
      expect(subject[:modal_attributes]).to be_valid_json
    end
  end
end
