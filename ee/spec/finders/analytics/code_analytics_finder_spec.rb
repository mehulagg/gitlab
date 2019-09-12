# frozen_string_literal: true

require 'spec_helper'

describe Analytics::CodeAnalyticsFinder do
  describe "#execute" do
    set(:project) { create(:project) }
    set(:file) { create(:analytics_repository_file, project: project, file_path: 'app/db/migrate/file.rb')}
    set(:first_commit) { create(:analytics_repository_commit, project: project) }
    set(:repo_file_edits) { create(:analytics_repository_file_edits, project: project, file_path: 'app/db/migrate/theother/file.rb') }

    it "tests the setup" do
      puts project.inspect
      puts file.inspect
      puts first_commit.inspect
      puts repo_file_edits.inspect
    end

    subject { described_class.new(project, 10.days.ago, Time.now).execute }

    context "with one file in given timerange" do
      it "returns a hash with one file and its edits" do
        expect(subject).to include(file[:file_path] => repo_file_edits[:num_edits])
      end
    end

    context "with multiple commits on the same file in given timerange" do
      set(:second_commit) { create(:analytics_repository_commit, project: project) }
      set(:second_repo_file_edits_record) { create(:analytics_repository_file_edits, project: project, analytics_repository_file: file, analytics_repository_commit: second_commit) }

      it "returns a hash of file with summed edits for all commits on the file" do
        expect(subject).to include(
          file[:file_path] => repo_file_edits[:num_edits] + second_repo_file_edits_record[:num_edits]
        )
      end
    end
  end
end
