# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Sitemaps::UrlExtractor do
  include Gitlab::Routing

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
        group_url(group),
        issues_group_url(group),
        merge_requests_group_url(group),
        group_packages_url(group),
        group_epics_url(group)
      ]

      expect(subject).to match_array(expected_urls)
    end
  end

  describe '.extract_from_project' do
    let_it_be_with_reload(:project) { create(:project) }

    let(:project_feature) { project.project_feature }

    subject { described_class.extract_from_project(project) }

    it 'returns several project urls' do
      expected_urls = [
        project_url(project),
        project_issues_url(project),
        project_merge_requests_url(project),
        project_snippets_url(project),
        project_wiki_url(project, Wiki::HOMEPAGE)
      ]

      expect(subject).to match_array(expected_urls)
    end

    context 'when wiki access level is' do
      context 'disabled' do
        it 'does not include wiki url' do
          project_feature.update!(wiki_access_level: ProjectFeature::DISABLED)

          expect(subject).not_to include(project_wiki_url(project, Wiki::HOMEPAGE))
        end
      end

      context 'private' do
        it 'does not include wiki url' do
          project_feature.update!(wiki_access_level: ProjectFeature::PRIVATE)

          expect(subject).not_to include(project_wiki_url(project, Wiki::HOMEPAGE))
        end
      end
    end

    context 'when snippets are disabled' do
      context 'disabled' do
        it 'does not include snippets url' do
          project_feature.update!(snippets_access_level: ProjectFeature::DISABLED)

          expect(subject).not_to include(project_snippets_url(project))
        end
      end

      context 'private' do
        it 'does not include snippets url' do
          project_feature.update!(snippets_access_level: ProjectFeature::PRIVATE)

          expect(subject).not_to include(project_snippets_url(project))
        end
      end
    end

    context 'when issues are disabled' do
      context 'disabled' do
        it 'does not include issues url' do
          project_feature.update!(issues_access_level: ProjectFeature::DISABLED)

          expect(subject).not_to include(project_issues_url(project))
        end
      end

      context 'private' do
        it 'does not include issues url' do
          project_feature.update!(issues_access_level: ProjectFeature::PRIVATE)

          expect(subject).not_to include(project_issues_url(project))
        end
      end
    end

    context 'when merge requests are disabled' do
      context 'disabled' do
        it 'does not include merge requests url' do
          project_feature.update!(merge_requests_access_level: ProjectFeature::DISABLED)

          expect(subject).not_to include(project_merge_requests_url(project))
        end
      end

      context 'private' do
        it 'does not include merge requests url' do
          project_feature.update!(merge_requests_access_level: ProjectFeature::PRIVATE)

          expect(subject).not_to include(project_merge_requests_url(project))
        end
      end
    end
  end
end
