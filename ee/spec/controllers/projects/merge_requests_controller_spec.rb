require 'spec_helper'

shared_examples 'approvals' do
  def json_response
    JSON.parse(response.body)
  end

  let!(:approver) { create(:approver, target: project) }
  let!(:user_approver) { create(:approver, target: project, user: user) }

  before do
    merge_request.update_attribute :approvals_before_merge, 2
    project.add_developer(approver.user)
  end

  describe 'approve' do
    before do
      post :approve,
           params: {
             namespace_id: project.namespace.to_param,
             project_id: project.to_param,
             id: merge_request.iid
           },
           format: :json
    end

    it 'approves the merge request' do
      approvals = json_response

      expect(response).to be_success
      expect(approvals['approvals_left']).to eq 1
      expect(approvals['approved_by'].size).to eq 1
      expect(approvals['approved_by'][0]['user']['username']).to eq user.username
      expect(approvals['user_has_approved']).to be true
      expect(approvals['user_can_approve']).to be false
      expect(approvals['suggested_approvers'].size).to eq 1
      expect(approvals['suggested_approvers'][0]['username']).to eq approver.user.username
    end
  end

  describe 'approvals' do
    let!(:approval) { create(:approval, merge_request: merge_request, user: approver.user) }

    def get_approvals
      get :approvals,
          params: {
            namespace_id: project.namespace.to_param,
            project_id: project.to_param,
            id: merge_request.iid
          },
          format: :json
    end

    it 'shows approval information' do
      get_approvals

      approvals = json_response

      expect(response).to be_success
      expect(approvals['approvals_left']).to eq 1
      expect(approvals['approved_by'].size).to eq 1
      expect(approvals['approved_by'][0]['user']['username']).to eq approver.user.username
      expect(approvals['user_has_approved']).to be false
      expect(approvals['user_can_approve']).to be true
      expect(approvals['suggested_approvers'].size).to eq 1
      expect(approvals['suggested_approvers'][0]['username']).to eq user.username
    end

    context 'with unauthorized group' do
      let(:private_group) { create(:group_with_members, :private) }

      before do
        create(:approver_group, target: merge_request, group: private_group)
      end

      it 'does not expose approvers from a private group the current user has no access to' do
        get_approvals

        approvals = json_response

        expect(response).to be_success
        expect(approvals['suggested_approvers'].size).to eq(0)
      end
    end
  end

  describe 'unapprove' do
    let!(:approval) { create(:approval, merge_request: merge_request, user: user) }

    before do
      delete :unapprove,
             params: {
               namespace_id: project.namespace.to_param,
               project_id: project.to_param,
               id: merge_request.iid
             },
             format: :json
    end

    it 'unapproves the merge request' do
      approvals = json_response

      expect(response).to be_success
      expect(approvals['approvals_left']).to eq 2
      expect(approvals['approved_by']).to be_empty
      expect(approvals['user_has_approved']).to be false
      expect(approvals['user_can_approve']).to be true
      expect(approvals['suggested_approvers'].size).to eq 2
    end
  end
end

describe Projects::MergeRequestsController do
  include ProjectForksHelper

  let(:project)       { create(:project, :repository) }
  let(:merge_request) { create(:merge_request_with_diffs, source_project: project, author: create(:user)) }
  let(:user)          { project.creator }
  let(:viewer)        { user }

  before do
    stub_feature_flags(approval_rules: false)
    sign_in(viewer)
  end

  it_behaves_like 'approvals'

  describe 'PUT update' do
    before do
      project.update(approvals_before_merge: 2)
    end

    def update_merge_request(params = {})
      post :update,
           params: {
             namespace_id: merge_request.target_project.namespace.to_param,
             project_id: merge_request.target_project.to_param,
             id: merge_request.iid,
             merge_request: params
           }
    end

    context 'when the merge request requires approval' do
      before do
        project.update(approvals_before_merge: 1)
      end

      it_behaves_like 'update invalid issuable', MergeRequest
    end

    context 'overriding approvers per MR' do
      before do
        project.update(approvals_before_merge: 1)
      end

      context 'enabled' do
        before do
          project.update(disable_overriding_approvers_per_merge_request: false)
        end

        it 'updates approvals' do
          update_merge_request(approvals_before_merge: 2)

          expect(merge_request.reload.approvals_before_merge).to eq(2)
        end

        it 'does not allow approvels before merge lower than the project setting' do
          update_merge_request(approvals_before_merge: 0)

          expect(merge_request.reload.approvals_before_merge).to eq(1)
        end

        it 'creates rules' do
          users = create_list(:user, 3)
          users.each { |user| project.add_developer(user) }

          update_merge_request(approval_rules_attributes: [
            { name: 'foo', user_ids: users.map(&:id), approvals_required: 3 }
          ])

          expect(merge_request.reload.approval_rules.size).to eq(1)

          rule = merge_request.reload.approval_rules.first

          expect(rule.name).to eq('foo')
          expect(rule.approvals_required).to eq(3)
        end
      end

      context 'disabled' do
        let(:new_approver) { create(:user) }
        let(:new_approver_group) { create(:approver_group) }

        before do
          project.add_developer(new_approver)
          project.update(disable_overriding_approvers_per_merge_request: true)
        end

        it 'does not update approvals_before_merge' do
          update_merge_request(approvals_before_merge: 2)

          expect(merge_request.reload.approvals_before_merge).to eq(nil)
        end

        it 'does not update approver_ids' do
          update_merge_request(approver_ids: [new_approver].map(&:id).join(','))

          expect(merge_request.reload.approver_ids).to be_empty
        end

        it 'does not update approver_group_ids' do
          update_merge_request(approver_group_ids: [new_approver_group].map(&:id).join(','))

          expect(merge_request.reload.approver_group_ids).to be_empty
        end
      end
    end

    shared_examples 'approvals_before_merge param' do
      before do
        project.update(approvals_before_merge: 2)
      end

      context 'approvals_before_merge not set for the existing MR' do
        context 'when it is less than the one in the target project' do
          before do
            update_merge_request(approvals_before_merge: 1)
          end

          it 'sets the param to the sames as the project' do
            expect(merge_request.reload.approvals_before_merge).to eq(2)
          end

          it 'updates the merge request' do
            expect(merge_request).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end

        context 'when it is equal to the one in the target project' do
          before do
            update_merge_request(approvals_before_merge: 2)
          end

          it 'sets the param to the same as the project' do
            expect(merge_request.reload.approvals_before_merge).to eq(2)
          end

          it 'updates the merge request' do
            expect(merge_request.reload).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end

        context 'when it is greater than the one in the target project' do
          before do
            update_merge_request(approvals_before_merge: 3)
          end

          it 'saves the param in the merge request' do
            expect(merge_request.reload.approvals_before_merge).to eq(3)
          end

          it 'updates the merge request' do
            expect(merge_request.reload).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end
      end

      context 'approvals_before_merge set for the existing MR' do
        before do
          merge_request.update_attribute(:approvals_before_merge, 4)
        end

        context 'when it is not set' do
          before do
            update_merge_request(title: 'New title')
          end

          it 'does not change the merge request' do
            expect(merge_request.reload.approvals_before_merge).to eq(4)
          end

          it 'updates the merge request' do
            expect(merge_request.reload).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end

        context 'when it is less than the one in the target project' do
          before do
            update_merge_request(approvals_before_merge: 1)
          end

          it 'sets the param to the same as the target project' do
            expect(merge_request.reload.approvals_before_merge).to eq(2)
          end

          it 'updates the merge request' do
            expect(merge_request.reload).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end

        context 'when it is equal to the one in the target project' do
          before do
            update_merge_request(approvals_before_merge: 2)
          end

          it 'sets the param to the same as the target project' do
            expect(merge_request.reload.approvals_before_merge).to eq(2)
          end

          it 'updates the merge request' do
            expect(merge_request.reload).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end

        context 'when it is greater than the one in the target project' do
          before do
            update_merge_request(approvals_before_merge: 3)
          end

          it 'saves the param in the merge request' do
            expect(merge_request.reload.approvals_before_merge).to eq(3)
          end

          it 'updates the merge request' do
            expect(merge_request.reload).to be_valid
            expect(response).to redirect_to(project_merge_request_path(merge_request.target_project, merge_request))
          end
        end
      end
    end

    context 'when the MR targets the project' do
      it_behaves_like 'approvals_before_merge param'
    end

    context 'when the project is a fork' do
      let(:upstream) { create(:project, :repository) }
      let(:project) { fork_project(upstream, nil, repository: true) }

      context 'when the MR target upstream' do
        let(:merge_request) { create(:merge_request, title: 'This is targeting upstream', source_project: project, target_project: upstream) }

        before do
          upstream.add_developer(user)
          upstream.update(approvals_before_merge: 2)
        end

        it_behaves_like 'approvals_before_merge param'
      end

      context 'when the MR target the fork' do
        let(:merge_request) { create(:merge_request, title: 'This is targeting the fork', source_project: project, target_project: project) }

        before do
          project.add_developer(user)
          project.update(approvals_before_merge: 0)
        end

        it_behaves_like 'approvals_before_merge param'
      end
    end
  end

  describe 'POST #rebase' do
    def post_rebase
      post :rebase, params: { namespace_id: project.namespace, project_id: project, id: merge_request }
    end

    def expect_rebase_worker_for(user)
      expect(RebaseWorker).to receive(:perform_async).with(merge_request.id, user.id)
    end

    context 'approvals pending' do
      let(:project) { create(:project, :repository, approvals_before_merge: 1) }

      it 'returns 200' do
        expect_rebase_worker_for(viewer)

        post_rebase

        expect(response.status).to eq(200)
      end
    end

    context 'with a forked project' do
      let(:forked_project) { fork_project(project, fork_owner, repository: true) }
      let(:fork_owner) { create(:user) }

      before do
        project.add_developer(fork_owner)
        merge_request.update!(source_project: forked_project)
        forked_project.add_reporter(user)
      end

      it_behaves_like 'approvals'
    end
  end
end
