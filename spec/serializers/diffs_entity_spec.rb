# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DiffsEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:request) { EntityRequest.new(project: project, current_user: user) }
  let(:merge_request) { create(:merge_request_with_diffs, target_project: project, source_project: project) }
  let(:merge_request_diffs) { merge_request.merge_request_diffs }

  let(:entity) do
    described_class.new(merge_request_diffs.first.diffs, request: request, merge_request: merge_request, merge_request_diffs: merge_request_diffs)
  end

  context 'as json' do
    subject { entity.as_json }

    it 'contains needed attributes' do
      expect(subject).to include(
        :real_size, :size, :branch_name,
        :target_branch_name, :commit, :merge_request_diff,
        :start_version, :latest_diff, :latest_version_path,
        :added_lines, :removed_lines, :render_overflow_warning,
        :email_patch_path, :plain_diff_path, :diff_files,
        :merge_request_diffs, :definition_path_prefix
      )
    end

    context "when a commit_id is passed" do
      let(:commits) { merge_request.commits }
      let(:entity) do
        described_class.new(
          merge_request_diffs.first.diffs,
          request: request,
          merge_request: merge_request,
          merge_request_diffs: merge_request_diffs,
          commit: commit
        )
      end

      subject { entity.as_json }

      context "when the passed commit is not the first or last in the group" do
        let(:commit) { commits.third }

        it 'includes commit references for previous and next' do
          expect(subject[:commit][:next_commit_id]).to eq(commits.second.id)
          expect(subject[:commit][:prev_commit_id]).to eq(commits.fourth.id)
        end
      end

      context "when the passed commit is the first in the group" do
        let(:commit) { commits.first }

        it 'includes commit references for nil and previous commit' do
          expect(subject[:commit][:next_commit_id]).to be_nil
          expect(subject[:commit][:prev_commit_id]).to eq(commits.second.id)
        end
      end

      context "when the passed commit is the last in the group" do
        let(:commit) { commits.last }

        it 'includes commit references for the next and nil' do
          expect(subject[:commit][:next_commit_id]).to eq(commits[-2].id)
          expect(subject[:commit][:prev_commit_id]).to be_nil
        end
      end
    end

    context 'when there are conflicts' do
      let(:conflicts) { double(files: []) }

      before do
        allow_next_instance_of(MergeRequests::Conflicts::ListService) do |instance|
          allow(instance).to receive(:conflicts).and_return(conflicts)
        end
      end

      it 'lines are parsed with passed conflicts' do
        expect(Gitlab::Git::Conflict::LineParser).to(
          receive(:new).exactly(17).times.with(anything, conflicts).and_call_original
        )

        subject
      end

      context 'when diff lines should not be highlighted' do
        before do
          allow(merge_request).to receive(:highlight_diff_conflicts?).and_return(false)
        end

        it 'conflicts has no impact on line parsing' do
          expect(Gitlab::Git::Conflict::LineParser).not_to receive(:new)

          subject
        end
      end
    end
  end
end
