# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::AuditEventsController do
  let_it_be(:user) { create(:user) }
  let_it_be(:owner) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:events) { create_list(:group_audit_event, 5, entity_id: group.id) }

  describe 'GET #index' do
    let(:sort) { nil }
    let(:entity_type) { nil }
    let(:entity_id) { nil }

    context 'authorized' do
      before do
        group.add_owner(owner)
        sign_in(owner)
      end

      context do
        let(:request) do
          get :index, params: { group_id: group.to_param, sort: sort, entity_type: entity_type, entity_id: entity_id }
        end

        context 'when audit_events feature is available' do
          let(:level) { Gitlab::Audit::Levels::Group.new(group: group) }
          let(:audit_logs_params) { ActionController::Parameters.new(sort: '', entity_type: '', entity_id: '', created_after: Date.today.beginning_of_month, created_before: Date.today.end_of_day).permit! }

          before do
            stub_licensed_features(audit_events: true)

            allow(Gitlab::Audit::Levels::Group).to receive(:new).and_return(level)
            allow(AuditLogFinder).to receive(:new).and_call_original
          end

          shared_examples 'AuditLogFinder params' do
            it 'has the correct params' do
              request

              expect(AuditLogFinder).to have_received(:new).with(
                level: level, params: audit_logs_params
              )
            end
          end

          it 'renders index with 200 status code' do
            request

            expect(response).to have_gitlab_http_status(:ok)
            expect(response).to render_template(:index)
          end

          context 'invokes AuditLogFinder with correct arguments' do
            it_behaves_like 'AuditLogFinder params'
          end

          context 'author' do
            context 'when no author entity type is specified' do
              it_behaves_like 'AuditLogFinder params'
            end

            context 'when the author entity type is specified' do
              let(:entity_type) { 'Author' }
              let(:entity_id) { 1 }
              let(:audit_logs_params) { ActionController::Parameters.new(sort: '', author_id: '1', created_after: Date.today.beginning_of_month, created_before: Date.today.end_of_day).permit! }

              it_behaves_like 'AuditLogFinder params'
            end
          end

          context 'ordering' do
            shared_examples 'orders by id descending' do
              it 'orders by id descending' do
                request

                actual_event_ids = assigns(:events).map { |event| event[:id] }
                expected_event_ids = events.map(&:id).reverse

                expect(actual_event_ids).to eq(expected_event_ids)
              end
            end

            context 'when no sort order is specified' do
              it_behaves_like 'orders by id descending'
            end

            context 'when sorting by latest events first' do
              let(:sort) { 'created_desc' }

              it_behaves_like 'orders by id descending'
            end

            context 'when sorting by oldest events first' do
              let(:sort) { 'created_asc' }

              it 'orders by id ascending' do
                request

                actual_event_ids = assigns(:events).map { |event| event[:id] }
                expected_event_ids = events.map(&:id)

                expect(actual_event_ids).to eq(expected_event_ids)
              end
            end

            context 'when sorting by an unsupported sort order' do
              let(:sort) { 'FOO' }

              it_behaves_like 'orders by id descending'
            end
          end

          context 'pagination' do
            it 'sets instance variables' do
              request

              expect(assigns(:is_last_page)).to be(true)
            end

            it 'paginates audit events, without casting a count query' do
              serializer = instance_spy(AuditEventSerializer)
              allow(AuditEventSerializer).to receive(:new).and_return(serializer)

              request

              expect(serializer).to have_received(:represent).with(kind_of(Kaminari::PaginatableWithoutCount))
            end
          end
        end
      end

      it_behaves_like 'tracking unique visits', :index do
        let(:request_params) { { group_id: group.to_param, sort: sort, entity_type: entity_type, entity_id: entity_id } }
        let(:target_id) { 'g_compliance_audit_events' }
      end
    end

    context 'unauthorized' do
      let(:request) do
        get :index, params: { group_id: group.to_param, sort: sort, entity_type: entity_type, entity_id: entity_id }
      end

      before do
        stub_licensed_features(audit_events: true)
        sign_in(user)
      end

      it 'renders 404' do
        request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
