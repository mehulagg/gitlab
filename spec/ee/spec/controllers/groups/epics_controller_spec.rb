require 'spec_helper'

describe Groups::EpicsController do
  let(:group) { create(:group, :private) }
  let(:epic) { create(:epic, group: group) }
  let(:user)  { create(:user) }

  before do
    sign_in(user)
  end

<<<<<<< HEAD
  describe 'GET #show' do
    def show_epic(format = :html)
      get :show, group_id: group, id: epic.to_param, format: format
    end
=======
  context 'when epics feature is disabled' do
    shared_examples '404 status' do
      it 'returns 404 status' do
        subject

        expect(response).to have_gitlab_http_status(404)
      end
    end

    describe 'GET #index' do
      subject { get :index, group_id: group }

      it_behaves_like '404 status'
    end

    describe 'GET #show' do
      subject { get :show, group_id: group, id: epic.to_param }

      it_behaves_like '404 status'
    end

    describe 'PUT #update' do
      subject { put :update, group_id: group, id: epic.to_param }

      it_behaves_like '404 status'
    end
  end

  context 'when epics feature is enabled' do
    before do
      stub_licensed_features(epics: true)
    end

    describe "GET #index" do
      let!(:epic_list) { create_list(:epic, 2, group: group) }

      before do
        sign_in(user)
        group.add_developer(user)
      end

      it "returns index" do
        get :index, group_id: group

        expect(response).to have_gitlab_http_status(200)
      end

      context 'with page param' do
        let(:last_page) { group.epics.page.total_pages }
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'

        before do
          allow(Kaminari.config).to receive(:default_per_page).and_return(1)
        end

        it 'redirects to last_page if page number is larger than number of pages' do
          get :index, group_id: group, page: (last_page + 1).to_param

          expect(response).to redirect_to(group_epics_path(page: last_page, state: controller.params[:state], scope: controller.params[:scope]))
        end

<<<<<<< HEAD
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template 'groups/ee/epics/show'
=======
        it 'renders the specified page' do
          get :index, group_id: group, page: last_page.to_param

          expect(assigns(:epics).current_page).to eq(last_page)
          expect(response).to have_gitlab_http_status(200)
        end
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'
      end
    end

    describe 'GET #show' do
      def show_epic(format = :html)
        get :show, group_id: group, id: epic.to_param, format: format
      end

      context 'when format is HTML' do
        it 'renders template' do
          group.add_developer(user)
          show_epic

          expect(response.content_type).to eq 'text/html'
          expect(response).to render_template 'groups/epics/show'
        end

        context 'with unauthorized user' do
          it 'returns a not found 404 response' do
            show_epic

            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'text/html'
          end
        end
      end

      context 'when format is JSON' do
        it 'returns epic' do
          group.add_developer(user)
          show_epic(:json)

          expect(response).to have_http_status(200)
          expect(response).to match_response_schema('entities/epic')
        end

<<<<<<< HEAD
  describe 'PUT #update' do
    before do
      group.add_user(user, :developer)
      put :update, group_id: group, id: epic.to_param, epic: { title: 'New title' }, format: :json
    end
=======
        context 'with unauthorized user' do
          it 'returns a not found 404 response' do
            show_epic(:json)
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'

            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'application/json'
          end
        end
      end
    end

    describe 'PUT #update' do
      before do
        group.add_developer(user)
        put :update, group_id: group, id: epic.to_param, epic: { title: 'New title' }, format: :json
      end

<<<<<<< HEAD
  describe 'GET #realtime_changes' do
    subject { get :realtime_changes, group_id: group, id: epic.to_param }
    it 'returns epic' do
      group.add_user(user, :developer)
      subject
=======
      it 'returns status 200' do
        expect(response.status).to eq(200)
      end
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'

      it 'updates the epic correctly' do
        expect(epic.reload.title).to eq('New title')
      end
    end

    describe 'GET #realtime_changes' do
      subject { get :realtime_changes, group_id: group, id: epic.to_param }
      it 'returns epic' do
        group.add_developer(user)
        subject

        expect(response.content_type).to eq 'application/json'
        expect(JSON.parse(response.body)).to include('title_text', 'title', 'description', 'description_text')
      end
<<<<<<< HEAD
=======

      context 'with unauthorized user' do
        it 'returns a not found 404 response' do
          subject

          expect(response).to have_http_status(404)
        end
      end
    end

    describe "DELETE #destroy" do
      before do
        sign_in(user)
      end

      it "rejects a developer to destroy an epic" do
        group.add_developer(user)
        delete :destroy, group_id: group, id: epic.to_param

        expect(response).to have_gitlab_http_status(404)
      end

      it "deletes the epic" do
        group.add_owner(user)
        delete :destroy, group_id: group, id: epic.to_param

        expect(response).to have_gitlab_http_status(302)
        expect(controller).to set_flash[:notice].to(/The epic was successfully deleted\./)
      end
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'
    end
  end
end
