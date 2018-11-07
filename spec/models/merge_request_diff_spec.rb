require 'spec_helper'

describe MergeRequestDiff do
  let(:diff_with_commits) { create(:merge_request).merge_request_diff }

  describe 'create new record' do
    subject { diff_with_commits }

    it { expect(subject).to be_valid }
    it { expect(subject).to be_persisted }
    it { expect(subject.commits.count).to eq(29) }
    it { expect(subject.diffs.count).to eq(20) }
    it { expect(subject.head_commit_sha).to eq('b83d6e391c22777fca1ed3012fce84f633d7fed0') }
    it { expect(subject.base_commit_sha).to eq('ae73cb07c9eeaf35924a10f713b364d32b2dd34f') }
    it { expect(subject.start_commit_sha).to eq('0b4bc9a49b562e85de7cc9e834518ea6828729b9') }
  end

  describe '.by_commit_sha' do
    subject(:by_commit_sha) { described_class.by_commit_sha(sha) }

    let!(:merge_request) { create(:merge_request, :with_diffs) }

    context 'with sha contained in' do
      let(:sha) { 'b83d6e391c22777fca1ed3012fce84f633d7fed0' }

      it 'returns merge request diffs' do
        expect(by_commit_sha).to eq([merge_request.merge_request_diff])
      end
    end

    context 'with sha not contained in' do
      let(:sha) { 'b83d6e3' }

      it 'returns empty result' do
        expect(by_commit_sha).to be_empty
      end
    end
  end

  describe '#latest' do
    let!(:mr) { create(:merge_request, :with_diffs) }
    let!(:first_diff) { mr.merge_request_diff }
    let!(:last_diff) { mr.create_merge_request_diff }

    it { expect(last_diff.reload).to be_latest }
    it { expect(first_diff.reload).not_to be_latest }
  end

  describe '#diffs' do
    let(:merge_request) { create(:merge_request, :with_diffs) }
    let!(:diff) { merge_request.merge_request_diff.reload }

    context 'when it was not cleaned by the system' do
      it 'returns persisted diffs' do
        expect(diff).to receive(:load_diffs).and_call_original

        diff.diffs.diff_files
      end
    end

    context 'when diff was cleaned by the system' do
      before do
        diff.clean!
      end

      it 'returns diffs from repository if can compare with current diff refs' do
        expect(diff).not_to receive(:load_diffs)

        expect(Compare)
          .to receive(:new)
          .with(instance_of(Gitlab::Git::Compare), merge_request.target_project,
                base_sha: diff.base_commit_sha, straight: false)
          .and_call_original

        diff.diffs
      end

      it 'returns persisted diffs if cannot compare with diff refs' do
        expect(diff).to receive(:load_diffs).and_call_original

        diff.update!(head_commit_sha: 'invalid-sha')

        diff.diffs.diff_files
      end

      it 'returns persisted diffs if diff refs does not exist' do
        expect(diff).to receive(:load_diffs).and_call_original

        diff.update!(start_commit_sha: nil, base_commit_sha: nil)

        diff.diffs.diff_files
      end
    end
  end

  describe '#raw_diffs' do
    context 'when the :ignore_whitespace_change option is set' do
      it 'creates a new compare object instead of loading from the DB' do
        expect(diff_with_commits).not_to receive(:load_diffs)
        expect(diff_with_commits.compare).to receive(:diffs).and_call_original

        diff_with_commits.raw_diffs(ignore_whitespace_change: true)
      end
    end

    context 'when the raw diffs are empty' do
      before do
        MergeRequestDiffFile.delete_all(merge_request_diff_id: diff_with_commits.id)
      end

      it 'returns an empty DiffCollection' do
        expect(diff_with_commits.raw_diffs).to be_a(Gitlab::Git::DiffCollection)
        expect(diff_with_commits.raw_diffs).to be_empty
      end
    end

    context 'when the raw diffs exist' do
      it 'returns the diffs' do
        expect(diff_with_commits.raw_diffs).to be_a(Gitlab::Git::DiffCollection)
        expect(diff_with_commits.raw_diffs).not_to be_empty
      end

      context 'when the :paths option is set' do
        let(:diffs) { diff_with_commits.raw_diffs(paths: ['files/ruby/popen.rb', 'files/ruby/popen.rb']) }

        it 'only returns diffs that match the (old path, new path) given' do
          expect(diffs.map(&:new_path)).to contain_exactly('files/ruby/popen.rb')
        end

        it 'only serializes diff files found by query' do
          expect(diff_with_commits.merge_request_diff_files.count).to be > 10
          expect_any_instance_of(MergeRequestDiffFile).to receive(:to_hash).once

          diffs
        end

        it 'uses the diffs from the DB' do
          expect(diff_with_commits).to receive(:load_diffs)

          diffs
        end
      end
    end
  end

  describe '#save_diffs' do
    it 'saves collected state' do
      mr_diff = create(:merge_request).merge_request_diff

      expect(mr_diff.collected?).to be_truthy
    end

    it 'saves overflow state' do
      allow(Commit).to receive(:max_diff_options)
        .and_return(max_lines: 0, max_files: 0)

      mr_diff = create(:merge_request).merge_request_diff

      expect(mr_diff.overflow?).to be_truthy
    end

    it 'saves empty state' do
      allow_any_instance_of(described_class).to receive_message_chain(:compare, :commits)
        .and_return([])

      mr_diff = create(:merge_request).merge_request_diff

      expect(mr_diff.empty?).to be_truthy
    end

    it 'expands collapsed diffs before saving' do
      mr_diff = create(:merge_request, source_branch: 'expand-collapse-lines', target_branch: 'master').merge_request_diff
      diff_file = mr_diff.merge_request_diff_files.find_by(new_path: 'expand-collapse/file-5.txt')

      expect(diff_file.diff).not_to be_empty
    end

    it 'saves binary diffs correctly' do
      path = 'files/images/icn-time-tracking.pdf'
      mr_diff = create(:merge_request, source_branch: 'add-pdf-text-binary', target_branch: 'master').merge_request_diff
      diff_file = mr_diff.merge_request_diff_files.find_by(new_path: path)

      expect(diff_file).to be_binary
      expect(diff_file.diff).to eq(mr_diff.compare.diffs(paths: [path]).to_a.first.diff)
    end
  end

  describe '#commit_shas' do
    it 'returns all commit SHAs using commits from the DB' do
      expect(diff_with_commits.commit_shas).not_to be_empty
      expect(diff_with_commits.commit_shas).to all(match(/\h{40}/))
    end
  end

  describe '#compare_with' do
    it 'delegates compare to the service' do
      expect(CompareService).to receive(:new).and_call_original

      diff_with_commits.compare_with(nil)
    end

    it 'uses git diff A..B approach by default' do
      diffs = diff_with_commits.compare_with('0b4bc9a49b562e85de7cc9e834518ea6828729b9').diffs

      expect(diffs.size).to eq(21)
    end
  end

  describe '#commits_count' do
    it 'returns number of commits using serialized commits' do
      expect(diff_with_commits.commits_count).to eq(29)
    end
  end

  describe '#commits_by_shas' do
    let(:commit_shas) { diff_with_commits.commit_shas }

    it 'returns empty if no SHAs were provided' do
      expect(diff_with_commits.commits_by_shas([])).to be_empty
    end

    it 'returns one SHA' do
      commits = diff_with_commits.commits_by_shas([commit_shas.first, Gitlab::Git::BLANK_SHA])

      expect(commits.count).to eq(1)
    end

    it 'returns all matching SHAs' do
      commits = diff_with_commits.commits_by_shas(commit_shas)

      expect(commits.count).to eq(commit_shas.count)
      expect(commits.map(&:sha)).to match_array(commit_shas)
    end
  end

  describe '#modified_paths' do
    subject do
      diff = create(:merge_request_diff)
      create(:merge_request_diff_file, :new_file, merge_request_diff: diff)
      create(:merge_request_diff_file, :renamed_file, merge_request_diff: diff)
      diff
    end

    it 'returns affected file paths' do
      expect(subject.modified_paths).to eq(%w{foo bar baz})
    end
  end
end
