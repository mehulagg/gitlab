# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReleaseHighlight do
  let(:fixture_dir_glob) { Dir.glob(File.join('spec', 'fixtures', 'whats_new', '*.yml')) }
  let(:cache_mock) { double(:cache_mock) }
  let(:dot_com) { false }

  before do
    allow(Gitlab).to receive(:com?).and_return(dot_com)
    allow(Dir).to receive(:glob).with(Rails.root.join('data', 'whats_new', '*.yml')).and_return(fixture_dir_glob)

    expect(Rails).to receive(:cache).twice.and_return(cache_mock)
    expect(cache_mock).to receive(:fetch).with('whats_new:file_paths', expires_in: 1.hour).and_yield
  end

  after do
    ReleaseHighlight.instance_variable_set(:@file_paths, nil)
  end

  describe '#most_recent' do
    context 'with page param' do
      subject { ReleaseHighlight.most_recent(page: page) }

      before do
        allow(cache_mock).to receive(:fetch).and_yield
      end

      context 'when there is another page of results' do
        let(:page) { 2 }

        it 'responds with paginated results' do
          expect(subject[:items].first['title']).to eq('bright')
          expect(subject[:next_page]).to eq(3)
        end
      end

      context 'when there is NOT another page of results' do
        let(:page) { 3 }

        it 'responds with paginated results and no next_page' do
          expect(subject[:items].first['title']).to eq("It's gonna be a bright")
          expect(subject[:next_page]).to eq(nil)
        end
      end
    end

    context 'with no page param' do
      subject { ReleaseHighlight.most_recent }

      before do
        expect(cache_mock).to receive(:fetch).with('whats_new:release_items:file-20201225_01_05:page-1', expires_in: 1.hour).and_yield
      end

      it 'returns platform specific items and uses a cache key' do
        expect(subject[:items].count).to eq(1)
        expect(subject[:items].first['title']).to eq("bright and sunshinin' day")
        expect(subject[:next_page]).to eq(2)
      end

      context 'when Gitlab.com' do
        let(:dot_com) { true }

        it 'responds with a different set of data' do
          expect(subject[:items].count).to eq(1)
          expect(subject[:items].first['title']).to eq("I think I can make it now the pain is gone")
        end
      end

      context 'when recent release items do NOT exist' do
        before do
          allow(YAML).to receive(:safe_load).and_raise

          expect(Gitlab::ErrorTracking).to receive(:track_exception)
        end

        it 'fails gracefully and logs an error' do
          expect(subject).to be_nil
        end
      end
    end
  end
end
