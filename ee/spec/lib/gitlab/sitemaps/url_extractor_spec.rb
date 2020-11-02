# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Sitemaps::UrlExtractor do
  before do
    stub_default_url_options(host: 'localhost')
  end

  describe '.extract' do
    subject { described_class.extract(element) }

    context 'when element is a string' do
      let(:element) { "https://gitlab.com" }

      it 'returns the string without any processing' do
        expect(subject).to eq element
      end
    end

    context 'when element is a group' do
      let(:element) { build(:group) }

      it 'calls .extract_from_group' do
        expect(described_class).to receive(:extract_from_group)

        subject
      end
    end

    context 'when element is a project' do
      let(:element) { build(:project) }

      it 'calls .extract_from_project' do
        expect(described_class).to receive(:extract_from_project)

        subject
      end
    end

    context 'when element is unknown' do
      let(:element) { build(:user) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.extract_from_group' do
    let(:group) { build(:group) }

    subject { described_class.extract_from_group(group) }

    it 'returns several group urls' do
      expected_urls = [
        "http://localhost/#{group.full_path}",
        "http://localhost/groups/#{group.full_path}/-/issues",
        "http://localhost/groups/#{group.full_path}/-/merge_requests",
        "http://localhost/groups/#{group.full_path}/-/packages",
        "http://localhost/groups/#{group.full_path}/-/epics"
      ]

      expect(subject).to match_array(expected_urls)
    end
  end

  describe '.extract_from_project' do
    let(:project) { build(:project) }

    subject { described_class.extract_from_project(project) }

    it 'returns several project urls' do
      expected_urls = [
        "http://localhost/#{project.full_path}",
        "http://localhost/#{project.full_path}/-/issues",
        "http://localhost/#{project.full_path}/-/merge_requests",
        "http://localhost/#{project.full_path}/-/snippets",
        "http://localhost/#{project.full_path}/-/wikis/home"
      ]

      expect(subject).to match_array(expected_urls)
    end

    context 'when wiki is disabled' do
      let(:project) { build(:project, :wiki_disabled) }

      it 'does not include wiki url' do
        expect(subject).not_to include("http://localhost/#{project.full_path}/-/wiki_home")
      end
    end

    context 'when snippets are disabled' do
      let(:project) { build(:project, :snippets_disabled) }

      it 'does not include snippets url' do
        expect(subject).not_to include("http://localhost/#{project.full_path}/-/wiki_home")
      end
    end
  end
end
