# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Backup::Repositories do
  let(:progress) { StringIO.new }

  subject { described_class.new(progress) }

  before do
    allow(progress).to receive(:puts)
    allow(progress).to receive(:print)

    allow_next_instance_of(described_class) do |instance|
      allow(instance).to receive(:progress).and_return(progress)
    end
  end

  describe '#dump' do
    context 'hashed storage' do
      let_it_be(:project) { create(:project, :repository) }
      let_it_be(:group) { create(:group, :wiki_repo) }

      it 'creates repository bundles', :aggregate_failures do
        create(:wiki_page, container: group)

        subject.dump(max_concurrency: 1, max_storage_concurrency: 1)

        expect(File).to exist(File.join(Gitlab.config.backup.path, 'repositories', project.disk_path + '.bundle'))
        expect(File).to exist(File.join(Gitlab.config.backup.path, 'repositories', group.wiki.disk_path + '.bundle'))
      end
    end

    context 'no concurrency' do
      let_it_be(:groups) { create_list(:group, 5, :wiki_repo) }

      it 'creates the expected number of threads' do
        expect(Thread).not_to receive(:new)

        groups.each do |group|
          expect(subject).to receive(:dump_group).with(group).and_call_original
        end

        subject.dump(max_concurrency: 1, max_storage_concurrency: 1)
      end

      describe 'command failure' do
        it 'dump_group raises an error' do
          allow(subject).to receive(:dump_group).and_raise(IOError)

          expect { subject.dump(max_concurrency: 1, max_storage_concurrency: 1) }.to raise_error(IOError)
        end

        it 'group query raises an error' do
          allow(Group).to receive_message_chain(:includes, :find_each).and_raise(ActiveRecord::StatementTimeout)

          expect { subject.dump(max_concurrency: 1, max_storage_concurrency: 1) }.to raise_error(ActiveRecord::StatementTimeout)
        end
      end

      it 'avoids N+1 database queries' do
        control_count = ActiveRecord::QueryRecorder.new do
          subject.dump(max_concurrency: 1, max_storage_concurrency: 1)
        end.count

        create_list(:group, 2, :wiki_repo)

        expect do
          subject.dump(max_concurrency: 1, max_storage_concurrency: 1)
        end.not_to exceed_query_limit(control_count)
      end
    end
  end

  describe '#restore' do
    let_it_be(:project) { create(:project) }
    let_it_be(:group) { create(:group) }

    let(:next_path_to_bundle) do
      [
        Rails.root.join('spec/fixtures/lib/backup/wiki_repo.bundle'),
        Rails.root.join('spec/fixtures/lib/backup/project_repo.bundle')
      ].to_enum
    end

    it 'restores repositories from bundles', :aggregate_failures do
      allow_next_instance_of(described_class::BackupRestore) do |backup_restore|
        allow(backup_restore).to receive(:path_to_bundle).and_return(next_path_to_bundle.next)
      end

      subject.restore

      collect_commit_shas = -> (repo) { repo.commits('master', limit: 10).map(&:sha) }

      expect(collect_commit_shas.call(project.repository)).to eq(['393a7d860a5a4c3cc736d7eb00604e3472bb95ec'])
      expect(collect_commit_shas.call(group.wiki.repository)).to eq(['c74b9948d0088d703ee1fafeddd9ed9add2901ea'])
    end
  end
end
