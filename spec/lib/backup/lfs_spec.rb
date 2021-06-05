# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Backup::Lfs do
  let(:progress) { StringIO.new }

  subject(:backup) { described_class.new(progress) }

  describe '#initialize' do
    it 'uses the correct lfs dir' do
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p("#{tmpdir}/lfs-objects")

        allow(Gitlab.config.lfs).to receive(:storage_path) { tmpdir }

        expect(backup.app_files_dir).to eq("#{tmpdir}/lfs-objects")
      end
    end
  end

  describe '#dump' do
    before do
      allow(File).to receive(:realpath).with('/var/lfs-objects').and_return('/var/lfs-objects')
      allow(File).to receive(:realpath).with('/var/lfs-objects/..').and_return('/var')
      allow(Gitlab.config.lfs).to receive(:storage_path) { '/var' }
    end

    it 'uses the correct lfs dir' do
      expect(backup.app_files_dir).to eq('/var/lfs-objects')
    end

    it 'excludes tmp from backup tar' do
      expect(backup).to receive(:tar).and_return('blabla-tar')
      expect(backup).to receive(:run_pipeline!).with([%w(blabla-tar --exclude=lost+found --exclude=./tmp -C /var/lfs-objects -cf - .), 'gzip -c -1'], any_args).and_return([[true, true], ''])
      expect(backup).to receive(:pipeline_succeeded?).and_return(true)
      backup.dump
    end
  end
end
