# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Sitemaps::Generator do
  subject { described_class.execute }

  it 'returns error if the env is not .com' do
    expect(Gitlab).to receive(:com?).and_return(false)

    expect(subject).to eq "The sitemap can only be generated for Gitlab.com"
  end

  context 'when env is .com' do
    before do
      expect(Gitlab).to receive(:com?).and_return(true)
    end

    it 'returns error if group gitlab-org is not found' do
      expect(subject).to eq "The group 'gitlab-org' was not found"
    end

    context 'when group gitlab-org is present and public' do
      context 'and it is not public' do
        it 'returns and error' do
          create(:group, :internal, path: 'gitlab-org', name: "Gitlab Org Group")

          expect(subject).to eq "The group 'gitlab-org' was not found"
        end
      end

      context 'and it is public ' do
        let_it_be(:gitlab_org_group) { create(:group, :public, path: 'gitlab-org', name: "Gitlab Org Group") }
        let_it_be(:public_gitlab_org_project) { create(:project, :public, namespace: gitlab_org_group) }
        let_it_be(:internal_gitlab_org_project) { create(:project, :internal, namespace: gitlab_org_group) }
        let_it_be(:private_gitlab_org_project) { create(:project, :private, namespace: gitlab_org_group) }
        let_it_be(:public_subgroup) { create(:group, :public, path: 'group1', name: 'group1', parent: gitlab_org_group) }
        let_it_be(:internal_subgroup) { create(:group, :internal, path: 'group2', name: 'group2', parent: gitlab_org_group) }
        let_it_be(:public_subgroup_public_project) { create(:project, :public, namespace: public_subgroup) }
        let_it_be(:public_subgroup_internal_project) { create(:project, :internal, namespace: public_subgroup) }
        let_it_be(:internal_subgroup_private_project) { create(:project, :private, namespace: internal_subgroup) }
        let_it_be(:internal_subgroup_internal_project) { create(:project, :internal, namespace: internal_subgroup) }
        let_it_be(:other_project) { create(:project, :public) }

        it 'includes default explore routes and gitlab-org group routes' do
          create(:project_group_link, project: other_project, group: gitlab_org_group)

          content = subject.render

          expect(content).to include('/explore/projects')
          expect(content).to include('/explore/groups')
          expect(content).to include('/explore/snippets')
          expect(content).to include(gitlab_org_group.full_path)
          expect(content).to include(public_subgroup.full_path)
          expect(content).to include(public_gitlab_org_project.full_path)
          expect(content).to include(public_subgroup_public_project.full_path)

          expect(content).not_to include(internal_gitlab_org_project.full_path)
          expect(content).not_to include(private_gitlab_org_project.full_path)
          expect(content).not_to include(internal_subgroup.full_path)
          expect(content).not_to include(other_project.full_path)
          expect(content).not_to include(public_subgroup_internal_project.full_path)
          expect(content).not_to include(internal_subgroup_private_project.full_path)
          expect(content).not_to include(internal_subgroup_internal_project.full_path)
        end
      end
    end
  end
end
