# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::AuditLogsController do
  let_it_be(:admin) { create(:admin) }

  describe 'GET #index' do
    before do
      sign_in(admin)
    end

    context 'licensed' do
      before do
        stub_licensed_features(admin_audit_log: true)
      end

      context 'pagination' do
        it 'paginates audit events, without casting a count query' do
          create(:user_audit_event, created_at: 5.days.ago)

          serializer = instance_spy(AuditEventSerializer)
          allow(AuditEventSerializer).to receive(:new).and_return(serializer)

          get :index, params: { 'entity_type': 'User' }

          expect(serializer).to have_received(:represent).with(kind_of(Kaminari::PaginatableWithoutCount))
        end
      end

      it_behaves_like 'tracking unique visits', :index do
        let(:request_params) { { 'entity_type': 'User' } }
        let(:target_id) { 'i_compliance_audit_events' }
      end

      it 'tracks search event', :snowplow do
        get :index

        expect_snowplow_event(
          category: 'Admin::AuditLogsController',
          action: 'search_audit_event',
          user: admin
        )
      end
    end
  end
end
