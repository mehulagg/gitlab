# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::ProjectsController do
  let_it_be(:user) { create(:user) }

  describe '#removed' do
    render_views
    subject { get :removed, format: :json }

    before do
      sign_in(user)

      allow(Kaminari.config).to receive(:default_per_page).and_return(1)
    end

    shared_examples 'returns not found' do
      it do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when licensed' do
      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: true)
      end

      context 'for admin users', :enable_admin_mode do
        let_it_be(:user) { create(:admin) }
        let_it_be(:projects) { create_list(:project, 2, :archived, creator: user, marked_for_deletion_at: 3.days.ago) }

        it 'returns success' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'paginates the records' do
          subject

          expect(assigns(:projects).count).to eq(1)
        end

        it 'accounts total removable projects' do
          subject

          expect(assigns(:removed_projects_count).count).to eq(2)
        end
      end

      context 'for non-admin users' do
        it_behaves_like 'returns not found'
      end
    end

    context 'when not licensed' do
      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: false)
      end

      it_behaves_like 'returns not found'
    end
  end
end
