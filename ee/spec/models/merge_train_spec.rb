# frozen_string_literal: true

require "spec_helper"

RSpec.describe MergeTrain do
  include ProjectForksHelper

  let_it_be(:project) { create(:project, :repository) }

  it { is_expected.to belong_to(:merge_request) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:pipeline) }

  before do
    allow(AutoMergeProcessWorker).to receive(:perform_async)
  end

  shared_context 'various merge trains' do
    let_it_be(:merge_train_idle) { create(:merge_train, :idle) }
    let_it_be(:merge_train_stale) { create(:merge_train, :stale) }
    let_it_be(:merge_train_fresh) { create(:merge_train, :fresh) }
    let_it_be(:merge_train_merged) { create(:merge_train, :merged) }
    let_it_be(:merge_train_merging) { create(:merge_train, :merging) }
  end

  describe '.active' do
    subject { described_class.active }

    include_context 'various merge trains'

    it 'returns only active merge trains' do
      is_expected.to contain_exactly(merge_train_idle, merge_train_stale, merge_train_fresh)
    end
  end

  describe '.complete' do
    subject { described_class.complete }

    include_context 'various merge trains'

    it 'returns only merged merge trains' do
      is_expected.to contain_exactly(merge_train_merged, merge_train_merging)
    end
  end

  describe '.for_target' do
    subject { described_class.for_target(project_id, branch) }

    let!(:merge_train_1) { create(:merge_train) }
    let!(:merge_train_2) { create(:merge_train) }

    context "when target merge train 1's project" do
      let(:project_id) { merge_train_1.target_project_id }
      let(:branch) { merge_train_1.target_branch }

      it 'returns merge train 1 only' do
        is_expected.to eq([merge_train_1])
      end
    end

    context "when target merge train 2's project" do
      let(:project_id) { merge_train_2.target_project_id }
      let(:branch) { merge_train_2.target_branch }

      it 'returns merge train 2 only' do
        is_expected.to eq([merge_train_2])
      end
    end
  end

  describe '.by_id' do
    subject { described_class.by_id }

    let!(:merge_train_1) { create(:merge_train, target_project: project, target_branch: 'master') }
    let!(:merge_train_2) { create(:merge_train, target_project: project, target_branch: 'master') }

    it 'returns merge trains by id ASC' do
      is_expected.to eq([merge_train_1, merge_train_2])
    end
  end

  describe '.all_active_mrs_in_train' do
    subject { described_class.all_active_mrs_in_train(target_project_id, target_branch) }

    let(:target_project_id) { merge_request.target_project_id }
    let(:target_branch) { merge_request.target_branch }
    let!(:merge_request) { create_merge_request_on_train }

    it 'returns the merge request' do
      is_expected.to eq([merge_request])
    end

    context 'when the other merge request is on the merge train' do
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the merge requests' do
        is_expected.to eq([merge_request, merge_request_2])
      end
    end

    context 'when the merge request has already been merged' do
      let!(:merge_request) { create_merge_request_on_train(status: :merged) }

      it { is_expected.to be_empty }
    end

    context 'when the merge request is not on merge train' do
      let(:merge_request) { create(:merge_request) }

      it 'returns empty array' do
        is_expected.to be_empty
      end
    end
  end

  describe '.first_in_train' do
    subject { described_class.first_in_train(target_project_id, target_branch) }

    let(:target_project_id) { merge_request.target_project_id }
    let(:target_branch) { merge_request.target_branch }
    let!(:merge_request) { create_merge_request_on_train }

    it 'returns the merge request' do
      is_expected.to eq(merge_request)
    end

    context 'when the other merge request is on the merge train' do
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the merge request' do
        is_expected.to eq(merge_request)
      end
    end

    context 'when the merge request has already been merged' do
      let!(:merge_request) { create_merge_request_on_train(status: :merged) }

      it { is_expected.to be_nil }
    end

    context 'when the merge request is not on merge train' do
      let(:merge_request) { create(:merge_request) }

      it 'returns empty array' do
        is_expected.to be_nil
      end
    end
  end

  describe '.first_in_trains' do
    let!(:first_on_master) { create_merge_request_on_train(target_branch: 'master', source_branch: 'feature-1') }
    let!(:second_on_master) { create_merge_request_on_train(target_branch: 'master', source_branch: 'feature-2') }

    let!(:first_on_stable) { create_merge_request_on_train(target_branch: 'stable', source_branch: 'feature-1-backport') }
    let!(:second_on_stable) { create_merge_request_on_train(target_branch: 'stable', source_branch: 'feature-2-backport') }

    subject { described_class.first_in_trains(project) }

    it 'returns only first merge requests per merge train' do
      is_expected.to contain_exactly(first_on_master, first_on_stable)
    end

    context 'when first_on_master has already been merged' do
      let!(:first_on_master) { create_merge_request_on_train(target_branch: 'master', source_branch: 'feature-1', status: :merged) }

      it 'returns second on master as active MR' do
        is_expected.to contain_exactly(second_on_master, first_on_stable)
      end
    end
  end

  describe '.first_in_train_from' do
    subject { described_class.first_in_train_from(merge_request_ids) }

    context 'when arguments is null' do
      let(:merge_request_ids) { nil }

      it 'raises an error' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'when there are two merge requests on the same merge train' do
      let(:merge_request_ids) { [merge_request_1.id, merge_request_2.id] }
      let!(:merge_request_1) { create_merge_request_on_train }
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the first merge request on the merge train from the given ids' do
        is_expected.to eq(merge_request_1)
      end

      context 'when the first merge request has already been merged' do
        let!(:merge_request_1) { create_merge_request_on_train(status: :merged) }

        it 'returns the first active merge request on the merge train from the given ids' do
          is_expected.to eq(merge_request_2)
        end
      end

      context "when specifies merge request 2's id only" do
        let(:merge_request_ids) { [merge_request_2.id] }

        it 'returns the first merge request on the merge train from the given ids' do
          is_expected.to eq(merge_request_2)
        end
      end
    end
  end

  describe '.last_complete_mr_in_train' do
    subject { described_class.last_complete_mr_in_train(target_project_id, target_branch) }

    let(:target_project_id) { project.id }
    let(:target_branch) { 'master' }

    context 'when there is a merge request on train' do
      let!(:merge_request_1) { create_merge_request_on_train }

      context 'when the merge request has already been merged' do
        let!(:merge_request_1) { create_merge_request_on_train(status: :merged) }

        it 'returns the merge request' do
          is_expected.to eq(merge_request_1)
        end

        context 'when there is another merge request on train and it has been merged' do
          let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome', status: :merged) }

          it 'returns the last merge request' do
            is_expected.to eq(merge_request_2)
          end
        end
      end

      context 'when the merge request has not been merged yet' do
        it 'returns nothing' do
          is_expected.to be_nil
        end
      end
    end

    context 'when there are no merge requests on train' do
      it 'returns nothing' do
        is_expected.to be_nil
      end
    end
  end

  describe '.sha_exists_in_history?' do
    subject { described_class.sha_exists_in_history?(target_project_id, target_branch, target_sha, limit: limit) }

    let(:target_project_id) { project.id }
    let(:target_branch) { 'master' }
    let(:target_sha) { '' }
    let(:limit) { 20 }

    context 'when there is a merge request on train' do
      let!(:merge_request_1) { create_merge_request_on_train }
      let(:merge_commit_sha_1) { Digest::SHA1.hexdigest 'test-1' }
      let(:target_sha) { merge_commit_sha_1 }

      context 'when the merge request has already been merging' do
        let!(:merge_request_1) { create_merge_request_on_train(status: :merging) }

        before do
          merge_request_1.update_column(:in_progress_merge_commit_sha, merge_commit_sha_1)
        end

        it { is_expected.to eq(true) }
      end

      context 'when the merge request has already been merged' do
        let!(:merge_request_1) { create_merge_request_on_train(status: :merged) }

        before do
          merge_request_1.update_column(:merge_commit_sha, merge_commit_sha_1)
        end

        it { is_expected.to eq(true) }
      end

      context 'when there is another merge request on train and it has been merged' do
        let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome', status: :merged) }
        let(:merge_commit_sha_2) { Digest::SHA1.hexdigest 'test-2' }
        let(:target_sha) { merge_commit_sha_2 }

        before do
          merge_request_2.update_column(:merge_commit_sha, merge_commit_sha_2)
        end

        it { is_expected.to eq(true) }

        context 'when limit is 1' do
          let(:limit) { 1 }
          let(:target_sha) { merge_commit_sha_1 }

          it { is_expected.to eq(false) }
        end
      end

      context 'when the merge request has not been merged yet' do
        it { is_expected.to eq(false) }
      end
    end

    context 'when there are no merge requests on train' do
      it { is_expected.to eq(false) }
    end
  end

  describe '.total_count_in_train' do
    subject { described_class.total_count_in_train(merge_request) }

    let!(:merge_request) { create_merge_request_on_train }

    it 'returns the merge request' do
      is_expected.to eq(1)
    end

    context 'when the other merge request is on the merge train' do
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the merge request' do
        is_expected.to eq(2)
      end
    end

    context 'when the merge request has already been merged' do
      let!(:merge_request) { create_merge_request_on_train(status: :merged) }

      it 'returns zero' do
        is_expected.to be(0)
      end
    end

    context 'when the merge request is not on merge train' do
      let(:merge_request) { create(:merge_request) }

      it 'returns empty array' do
        is_expected.to be(0)
      end
    end
  end

  describe '#all_next' do
    subject { merge_train.all_next }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    it 'returns nil' do
      is_expected.to be_empty
    end

    context 'when the other merge request is on the merge train' do
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the next merge requests' do
        is_expected.to eq([merge_request_2])
      end
    end
  end

  describe '#all_prev' do
    subject { merge_train.all_prev }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    context 'when the merge request is at first on the train' do
      it 'returns nil' do
        is_expected.to be_empty
      end
    end

    context 'when the merge request is at last on the train' do
      let(:merge_train) { merge_request_2.merge_train }
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the previous merge requests' do
        is_expected.to eq([merge_request])
      end

      context 'when the previous merge request has already been merged' do
        let!(:merge_request) { create_merge_request_on_train(status: :merged) }

        it 'returns empty array' do
          is_expected.to be_empty
        end
      end
    end
  end

  describe '#next' do
    subject { merge_train.next }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    context 'when the merge request is at last on the train' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when the other merge request is on the merge train' do
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the next merge request' do
        is_expected.to eq(merge_request_2)
      end
    end
  end

  describe '#prev' do
    subject { merge_train.prev }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    context 'when the merge request is at first on the train' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when the merge request is at last on the train' do
      let(:merge_train) { merge_request_2.merge_train }
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it 'returns the next merge request' do
        is_expected.to eq(merge_request)
      end
    end
  end

  describe '#first_in_train?' do
    subject { merge_train.first_in_train? }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    it { is_expected.to be_truthy }

    context 'when the other merge request is on the merge train' do
      let(:merge_train) { merge_request_2.merge_train }
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it { is_expected.to be_falsy }
    end
  end

  describe '#follower_in_train?' do
    subject { merge_train.follower_in_train? }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    it { is_expected.to be_falsy }

    context 'when the other merge request is on the merge train' do
      let(:merge_train) { merge_request_2.merge_train }
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it { is_expected.to be_truthy }
    end
  end

  describe '#index' do
    subject { merge_train.index }

    let(:merge_train) { merge_request.merge_train }
    let!(:merge_request) { create_merge_request_on_train }

    it { is_expected.to eq(0) }

    context 'when the merge train is at the second queue' do
      let(:merge_train) { merge_request_2.merge_train }
      let!(:merge_request_2) { create_merge_request_on_train(source_branch: 'improve/awesome') }

      it { is_expected.to eq(1) }
    end
  end

  describe 'status transition' do
    context 'when status is idle' do
      let(:merge_train) { create(:merge_train) }

      context 'and transits to fresh' do
        let!(:pipeline) { create(:ci_pipeline) }

        it 'refreshes the state and set a pipeline' do
          merge_train.refresh_pipeline!(pipeline.id)

          expect(merge_train).to be_fresh
          expect(merge_train.pipeline).to eq(pipeline)
        end
      end

      context 'and transits to merged' do
        it 'does not allow the transition' do
          expect { merge_train.finish_merge! }
            .to raise_error(StateMachines::InvalidTransition)
        end
      end

      context 'and transits to stale' do
        it 'does not allow the transition' do
          expect { merge_train.outdate_pipeline! }
            .to raise_error(StateMachines::InvalidTransition)
        end
      end
    end

    context 'when status is fresh' do
      let(:merge_train) { create(:merge_train, :fresh) }

      context 'and transits to merged' do
        it 'does not allow the transition' do
          expect { merge_train.finish_merge! }
            .to raise_error(StateMachines::InvalidTransition)
        end
      end

      context 'and transits to stale' do
        it 'refreshes asynchronously' do
          expect(AutoMergeProcessWorker)
            .to receive(:perform_async).with(merge_train.merge_request_id).once

          merge_train.outdate_pipeline!
        end
      end
    end

    context 'when status is merging' do
      let!(:merge_train) { create(:merge_train, :merging) }

      context 'and transits to merged' do
        it 'persists duration and merged_at' do
          expect(merge_train.duration).to be_nil
          expect(merge_train.merged_at).to be_nil

          Timecop.freeze(1.hour.from_now) do
            merge_train.finish_merge!

            merge_train.reload
            expect(merge_train.merged_at.to_i).to eq(Time.zone.now.to_i)
            expect(merge_train.duration).to eq(1.hour.to_i)
          end
        end

        it 'cleans up train ref' do
          expect(merge_train).to receive(:cleanup_ref)

          merge_train.finish_merge!
        end
      end
    end

    context 'when status is merged' do
      let(:merge_train) { create(:merge_train, :merged) }

      context 'and transits to merged' do
        it 'does not allow the transition' do
          expect { merge_train.finish_merge! }
            .to raise_error(StateMachines::InvalidTransition)
        end
      end
    end
  end

  describe '#destroy' do
    subject { merge_train.destroy }

    context 'when merge train has a pipeline' do
      let(:merge_train) { create(:merge_train, pipeline: pipeline) }
      let(:pipeline) { create(:ci_pipeline, :running) }
      let(:build) { create(:ci_build, :running, pipeline: pipeline) }

      it 'cancels the jobs in the pipeline' do
        expect { subject }.to change { build.reload.status }.from('running').to('canceled')
      end
    end
  end

  describe '#cleanup_ref' do
    subject { merge_train.cleanup_ref }

    let(:merge_train) { create(:merge_train) }

    it 'executes cleanup_refs for merge request' do
      expect(merge_train.merge_request).to receive(:cleanup_refs).with(only: :train)

      subject
    end
  end

  describe '#active?' do
    subject { merge_train.active? }

    context 'when status is idle' do
      let(:merge_train) { create(:merge_train, :idle) }

      it { is_expected.to eq(true) }
    end

    context 'when status is merged' do
      let(:merge_train) { create(:merge_train, :merged) }

      it { is_expected.to eq(false) }
    end
  end

  def create_merge_request_on_train(target_project: project, target_branch: 'master', source_project: project, source_branch: 'feature', status: :idle)
    create(:merge_request,
      :on_train,
      target_branch: target_branch,
      target_project: target_project,
      source_branch: source_branch,
      source_project: source_project,
      status: MergeTrain.state_machines[:status].states[status].value)
  end
end
