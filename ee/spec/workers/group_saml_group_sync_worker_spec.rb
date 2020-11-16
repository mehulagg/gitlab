# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupSamlGroupSyncWorker do
  describe '#perform' do
    let_it_be(:user) { create(:user) }

    let_it_be(:top_level_group) { create(:group) }
    let_it_be(:top_level_group_link) { create(:saml_group_link, group: top_level_group) }

    let_it_be(:group) { create(:group, parent: top_level_group) }
    let_it_be(:group_link) { create(:saml_group_link, group: group) }

    context 'when the group does not have group_saml_group_sync feature licensed' do
      before do
        create(:saml_provider, group: top_level_group, enabled: true)
      end

      it 'does not call the sync service' do
        expect(Groups::SyncService).not_to receive(:new)

        perform([top_level_group_link.id])
      end
    end

    context 'when the group has group_saml_group_sync feature licensed' do
      before do
        stub_licensed_features(group_saml_group_sync: true)
        stub_feature_flags(saml_group_links: true)
      end

      context 'when SAML is not enabled' do
        it 'does not call the sync service' do
          expect(Groups::SyncService).not_to receive(:new)

          perform([top_level_group_link.id])
        end
      end

      context 'when SAML is enabled' do
        before do
          create(:saml_provider, group: top_level_group, enabled: true)
        end

        it 'calls the sync service with the group links' do
          stub_sync_service_expectation([top_level_group_link, group_link])

          perform([top_level_group_link.id, group_link.id])
        end

        it 'does not call the sync service when the user does not exist' do
          expect(Groups::SyncService).not_to receive(:new)

          described_class.new.perform(non_existing_record_id, top_level_group.id, [group_link])
        end

        context 'when a group link falls outside the top-level group' do
          let(:outside_group_link) { create(:saml_group_link, group: create(:group)) }

          it 'drops group links outside the top level group' do
            stub_sync_service_expectation([group_link])

            perform([outside_group_link.id, group_link])
          end
        end
      end
    end

    def stub_sync_service_expectation(group_links)
      expect(Groups::SyncService).to receive(:new).with(nil, user, group_links: group_links).and_call_original
    end

    def perform(group_links)
      described_class.new.perform(user.id, top_level_group.id, group_links)
    end
  end
end
