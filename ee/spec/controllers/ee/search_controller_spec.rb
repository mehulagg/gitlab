# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SearchController, :elastic do
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'GET #show' do
    context 'unique users tracking' do
      before do
        stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
        allow(Gitlab::UsageDataCounters::HLLRedisCounter).to receive(:track_event)
      end

      context 'i_search_advanced' do
        it_behaves_like 'tracking unique hll events' do
          subject(:request) { get :show, params: { scope: 'projects', search: 'term' } }

          let(:target_id) { 'i_search_advanced' }
          let(:expected_type) { instance_of(String) }
        end
      end

      context 'i_search_paid' do
        let_it_be(:group) { create(:group) }

        let(:request_params) { { group_id: group.id, scope: 'blobs', search: 'term' } }
        let(:target_id) { 'i_search_paid' }

        context 'on Gitlab.com' do
          before do
            allow(::Gitlab).to receive(:com?).and_return(true)
            stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
          end

          it_behaves_like 'tracking unique hll events' do
            subject(:request) { get :show, params: request_params }

            let(:expected_type) { instance_of(String) }
          end
        end

        context 'self-managed instance' do
          before do
            allow(::Gitlab).to receive(:com?).and_return(false)
          end

          context 'license is available' do
            before do
              stub_licensed_features(elastic_search: true)
            end

            it_behaves_like 'tracking unique hll events' do
              subject(:request) { get :show, params: request_params }

              let(:expected_type) { instance_of(String) }
            end
          end

          it 'does not track if there is no license available' do
            stub_licensed_features(elastic_search: false)
            expect(Gitlab::UsageDataCounters::HLLRedisCounter).not_to receive(:track_event).with(target_id, values: instance_of(String))

            get :show, params: request_params, format: :html
          end
        end
      end
    end

    shared_examples 'renders the elasticsearch tabs if elasticsearch is enabled' do
      using RSpec::Parameterized::TableSyntax

      render_views

      subject { get :show, params: request_params, format: :html }

      where(:scope) { %w[projects issues merge_requests milestones epics notes blobs commits wiki_blobs users] }

      with_them do
        context 'when elasticsearch is enabled' do
          before do
            stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
          end

          it 'shows the elasticsearch tabs' do
            subject

            expect(response.body).to have_link('Code')
            expect(response.body).to have_link('Wiki')
            expect(response.body).to have_link('Comments')
            expect(response.body).to have_link('Commits')
          end
        end

        context 'when elasticsearch is disabled' do
          before do
            stub_ee_application_setting(elasticsearch_search: false, elasticsearch_indexing: false)
          end

          it 'does not show the elasticsearch tabs' do
            subject

            expect(response.body).not_to have_link('Code')
            expect(response.body).not_to have_link('Wiki')
            expect(response.body).not_to have_link('Comments')
            expect(response.body).not_to have_link('Commits')
          end
        end
      end
    end

    context 'global search' do
      let(:request_params) { { scope: scope, search: 'term' } }

      it_behaves_like 'renders the elasticsearch tabs if elasticsearch is enabled'
    end

    context 'group search' do
      let_it_be(:group) { create(:group) }

      let(:request_params) { { group_id: group.id, scope: scope, search: 'term' } }

      it_behaves_like 'renders the elasticsearch tabs if elasticsearch is enabled'
    end
  end
end
