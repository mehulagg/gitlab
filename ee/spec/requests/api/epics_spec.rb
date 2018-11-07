require 'spec_helper'

describe API::Epics do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, :public, group: group) }
  let(:epic) { create(:epic, group: group) }
  let(:params) { nil }

  shared_examples 'error requests' do
    context 'when epics feature is disabled' do
      it 'returns 403 forbidden error' do
        group.add_developer(user)

        get api(url, user), params

        expect(response).to have_gitlab_http_status(403)
      end

      context 'when epics feature is enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'returns 401 unauthorized error for non authenticated user' do
          get api(url), params

          expect(response).to have_gitlab_http_status(401)
        end

        it 'returns 404 not found error for a user without permissions to see the group' do
          project.update(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
          group.update(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

          get api(url, user), params

          expect(response).to have_gitlab_http_status(404)
        end
      end
    end
  end

  shared_examples 'can admin epics' do
    let(:extra_date_fields) { %w[start_date_is_fixed start_date_fixed due_date_is_fixed due_date_fixed] }

    context 'when permission is absent' do
      RSpec::Matchers.define_negated_matcher :exclude, :include

      it 'returns epic with extra date fields' do
        get api(url, user), params

        expect(Array.wrap(JSON.parse(response.body))).to all(exclude(*extra_date_fields))
      end
    end

    context 'when permission is present' do
      before do
        group.add_maintainer(user)
      end

      it 'returns epic with extra date fields' do
        get api(url, user), params

        expect(Array.wrap(JSON.parse(response.body))).to all(include(*extra_date_fields))
      end
    end
  end

  describe 'GET /groups/:id/epics' do
    let(:url) { "/groups/#{group.path}/epics" }

    it_behaves_like 'error requests'

    context 'when the request is correct' do
      before do
        stub_licensed_features(epics: true)

        get api(url, user)
      end

      it 'returns 200 status' do
        expect(response).to have_gitlab_http_status(200)
      end

      it 'matches the response schema' do
        expect(response).to match_response_schema('public_api/v4/epics', dir: 'ee')
      end
    end

    context 'with multiple epics' do
      let(:user2) { create(:user) }
      let!(:epic) do
        create(:epic,
               group: group,
               state: :closed,
               created_at: 3.days.ago,
               updated_at: 2.days.ago)
      end
      let!(:epic2) do
        create(:epic,
               author: user2,
               group: group,
               title: 'foo',
               description: 'bar',
               created_at: 2.days.ago,
               updated_at: 3.days.ago)
      end
      let!(:label) { create(:group_label, title: 'a-test', group: group) }
      let!(:label_link) { create(:label_link, label: label, target: epic2) }

      before do
        stub_licensed_features(epics: true)
      end

      def expect_array_response(expected)
        items = json_response.map { |i| i['id'] }

        expect(items).to eq(expected)
      end

      it 'returns epics authored by the given author id' do
        get api(url, user), author_id: user2.id

        expect_array_response([epic2.id])
      end

      it 'returns epics matching given search string for title' do
        get api(url, user), search: epic2.title

        expect_array_response([epic2.id])
      end

      it 'returns epics matching given search string for description' do
        get api(url, user), search: epic2.description

        expect_array_response([epic2.id])
      end

      it 'returns epics matching given status' do
        get api(url, user), state: :opened

        expect_array_response([epic2.id])
      end

      it 'returns all epics when state set to all' do
        get api(url, user), state: :all

        expect_array_response([epic2.id, epic.id])
      end

      it 'sorts by created_at descending by default' do
        get api(url, user)

        expect_array_response([epic2.id, epic.id])
      end

      it 'sorts ascending when requested' do
        get api(url, user), sort: :asc

        expect_array_response([epic.id, epic2.id])
      end

      it 'sorts by updated_at descending when requested' do
        get api(url, user), order_by: :updated_at

        expect_array_response([epic.id, epic2.id])
      end

      it 'sorts by updated_at ascending when requested' do
        get api(url, user), order_by: :updated_at, sort: :asc

        expect_array_response([epic2.id, epic.id])
      end

      it 'returns an array of labeled epics' do
        get api(url, user), labels: label.title

        expect_array_response([epic2.id])
      end

      it_behaves_like 'can admin epics'
    end
  end

  describe 'GET /groups/:id/epics/:epic_iid' do
    let(:url) { "/groups/#{group.path}/epics/#{epic.iid}" }

    it_behaves_like 'error requests'

    context 'when the request is correct' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'returns 200 status' do
        get api(url, user)

        expect(response).to have_gitlab_http_status(200)
      end

      it 'matches the response schema' do
        get api(url, user)

        expect(response).to match_response_schema('public_api/v4/epic', dir: 'ee')
      end

      it_behaves_like 'can admin epics'
    end
  end

  describe 'POST /groups/:id/epics' do
    let(:url) { "/groups/#{group.path}/epics" }
    let(:params) do
      {
        title: 'new epic',
        description: 'epic description',
        labels: 'label1',
        due_date_fixed: '2018-07-17',
        due_date_is_fixed: true
      }
    end

    it_behaves_like 'error requests'

    context 'when epics feature is enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'when required parameter is missing' do
        it 'returns 400' do
          group.add_developer(user)

          post api(url, user), description: 'epic description'

          expect(response).to have_gitlab_http_status(400)
        end
      end

      context 'when the request is correct' do
        before do
          group.add_developer(user)

          post api(url, user), params
        end

        it 'returns 201 status' do
          expect(response).to have_gitlab_http_status(201)
        end

        it 'matches the response schema' do
          expect(response).to match_response_schema('public_api/v4/epic', dir: 'ee')
        end

        it 'creates a new epic' do
          epic = Epic.last

          expect(epic.title).to eq('new epic')
          expect(epic.description).to eq('epic description')
          expect(epic.start_date_fixed).to eq(nil)
          expect(epic.start_date_is_fixed).to be_falsey
          expect(epic.due_date_fixed).to eq(Date.new(2018, 7, 17))
          expect(epic.due_date_is_fixed).to eq(true)
          expect(epic.labels.first.title).to eq('label1')
        end

        context 'when deprecated start_date and end_date params are present' do
          let(:start_date) { Date.new(2001, 1, 1) }
          let(:due_date) { Date.new(2001, 1, 2) }
          let(:params) { { title: 'new epic', start_date: start_date, end_date: due_date } }

          it 'updates start_date_fixed and due_date_fixed' do
            result = Epic.last

            expect(result.start_date_fixed).to eq(start_date)
            expect(result.due_date_fixed).to eq(due_date)
          end
        end
      end
    end
  end

  describe 'PUT /groups/:id/epics/:epic_iid' do
    let(:url) { "/groups/#{group.path}/epics/#{epic.iid}" }
    let(:params) do
      {
        title: 'new title',
        description: 'new description',
        labels: 'label2',
        start_date_fixed: "2018-07-17",
        start_date_is_fixed: true
      }
    end

    it_behaves_like 'error requests'

    context 'when epics feature is enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'when a user does not have permissions to create an epic' do
        it 'returns 403 forbidden error' do
          put api(url, user), params

          expect(response).to have_gitlab_http_status(403)
        end
      end

      context 'when no param sent' do
        it 'returns 400' do
          group.add_developer(user)

          put api(url, user)

          expect(response).to have_gitlab_http_status(400)
        end
      end

      context 'when the request is correct' do
        before do
          group.add_developer(user)
        end

        context 'with basic params' do
          before do
            put api(url, user), params
          end

          it 'returns 200 status' do
            expect(response).to have_gitlab_http_status(200)
          end

          it 'matches the response schema' do
            expect(response).to match_response_schema('public_api/v4/epic', dir: 'ee')
          end

          it 'updates the epic' do
            result = epic.reload

            expect(result.title).to eq('new title')
            expect(result.description).to eq('new description')
            expect(result.labels.first.title).to eq('label2')
            expect(result.start_date).to eq(Date.new(2018, 7, 17))
            expect(result.start_date_fixed).to eq(Date.new(2018, 7, 17))
            expect(result.start_date_is_fixed).to eq(true)
            expect(result.due_date_fixed).to eq(nil)
            expect(result.due_date_is_fixed).to be_falsey
          end
        end

        context 'when state_event is close' do
          it 'allows epic to be closed' do
            put api(url, user), state_event: 'close'

            expect(epic.reload).to be_closed
          end
        end

        context 'when state_event is reopen' do
          it 'allows epic to be reopend' do
            epic.update!(state: 'closed')

            put api(url, user), state_event: 'reopen'

            expect(epic.reload).to be_opened
          end
        end

        context 'when deprecated start_date and end_date params are present' do
          let(:epic) { create(:epic, :use_fixed_dates, group: group) }
          let(:new_start_date) { epic.start_date + 1.day }
          let(:new_due_date) { epic.end_date + 1.day }

          it 'updates start_date_fixed and due_date_fixed' do
            put api(url, user), start_date: new_start_date, end_date: new_due_date

            result = epic.reload

            expect(result.start_date_fixed).to eq(new_start_date)
            expect(result.due_date_fixed).to eq(new_due_date)
          end
        end

        context 'when updating start_date_is_fixed by itself' do
          let(:epic) { create(:epic, :use_fixed_dates, group: group) }
          let(:new_start_date) { epic.start_date + 1.day }
          let(:new_due_date) { epic.end_date + 1.day }

          it 'updates start_date_is_fixed' do
            put api(url, user), start_date_is_fixed: false

            result = epic.reload

            expect(result.start_date_is_fixed).to eq(false)
          end
        end
      end
    end
  end

  describe 'DELETE /groups/:id/epics/:epic_iid' do
    let(:url) { "/groups/#{group.path}/epics/#{epic.iid}" }

    it_behaves_like 'error requests'

    context 'when epics feature is enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'when a user does not have permissions to destroy an epic' do
        it 'returns 403 forbidden error' do
          group.add_developer(user)

          delete api(url, user)

          expect(response).to have_gitlab_http_status(403)
        end
      end

      context 'when the request is correct' do
        before do
          group.add_owner(user)
        end

        it 'returns 204 status' do
          delete api(url, user)

          expect(response).to have_gitlab_http_status(204)
        end

        it 'removes an epic' do
          epic

          expect { delete api(url, user) }.to change { Epic.count }.from(1).to(0)
        end
      end
    end
  end
end
