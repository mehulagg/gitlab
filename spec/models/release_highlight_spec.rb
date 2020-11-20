# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReleaseHighlight do
  let(:fixture_dir_glob) { Dir.glob(File.join('spec', 'fixtures', 'whats_new', '*.yml')) }
  let(:cache_mock) { double(:cache_mock) }

  before do
    allow(Dir).to receive(:glob).with(Rails.root.join('data', 'whats_new', '*.yml')).and_return(fixture_dir_glob)
    allow(cache_mock).to receive(:fetch).with('release_highlight:file_paths', expires_in: 1.hour).and_yield
  end

  after do
    ReleaseHighlight.instance_variable_set(:@file_paths, nil)
  end

  describe '.for_version' do
    subject { ReleaseHighlight.for_version(version: version) }

    let(:version) { '1.1' }

    context 'with version param that exists' do
      it 'returns items from that version' do
        expect(subject.items.first['title']).to eq("It's gonna be a bright")
      end
    end

    context 'with version param that does NOT exist' do
      let(:version) { '84.0' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.paginated' do
    let(:dot_com) { false }

    before do
      allow(Gitlab).to receive(:com?).and_return(dot_com)
      expect(Rails).to receive(:cache).twice.and_return(cache_mock)
    end

    context 'with page param' do
      subject { ReleaseHighlight.paginated(page: page) }

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
      subject { ReleaseHighlight.paginated }

      before do
        expect(cache_mock).to receive(:fetch).with('release_highlight:items:file-20201225_01_05:page-1', expires_in: 1.hour).and_yield
      end

      it 'returns platform specific items and uses a cache key' do
        expect(subject[:items].count).to eq(1)
        expect(subject[:items].first['title']).to eq("bright and sunshinin' day")
        expect(subject[:next_page]).to eq(2)
      end

      it 'parses the body as markdown and returns html' do
        expect(subject[:items].first['body']).to match("<h2 id=\"bright-and-sunshinin-day\">bright and sunshinin’ day</h2>")
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
          allow(YAML).to receive(:safe_load).and_raise(Psych::Exception)

          expect(Gitlab::ErrorTracking).to receive(:track_exception)
        end

        it 'fails gracefully and logs an error' do
          expect(subject).to be_nil
        end
      end
    end
  end

  describe '.most_recent_version' do
    subject { ReleaseHighlight.most_recent_version }

    context 'when version exist' do
      let(:release_item) { double(:item) }

      before do
        allow(ReleaseHighlight).to receive(:paginated).and_return(double(:paginated, items: [release_item]))
        allow(release_item).to receive(:[]).with('release').and_return(84.0)
      end

      it { is_expected.to eq(84.0) }
    end

    context 'when most recent release highlights do NOT exist' do
      before do
        allow(ReleaseHighlight).to receive(:paginated).and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '.most_recent_item_count' do
    subject { ReleaseHighlight.most_recent_item_count }

    context 'when recent release items exist' do
      it 'returns the count from the most recent file' do
        allow(ReleaseHighlight).to receive(:paginated).and_return(double(:paginated, items: [double(:item)]))

        expect(subject).to eq(1)
      end
    end

    context 'when recent release items do NOT exist' do
      it 'returns nil' do
        allow(ReleaseHighlight).to receive(:paginated).and_return(nil)

        expect(subject).to be_nil
      end
    end
  end

  describe '.versions' do
    it 'returns versions from the file paths' do
      expect(ReleaseHighlight.versions).to eq(['1.5', '1.2', '1.1'])
    end
  end

  describe 'QueryResult' do
    subject { ReleaseHighlight::QueryResult.new(items: items, next_page: 2) }

    let(:items) { [:item] }

    it 'responds to map' do
      expect(subject.map(&:to_s)).to eq(items.map(&:to_s))
    end
  end
end
