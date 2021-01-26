# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectFeature do
  let(:project) { create(:project, :public) }
  let(:user) { create(:user) }

  describe '#feature_available?' do
    let(:features) { %w(issues wiki builds merge_requests snippets repository pages) }

    context 'when features are enabled only for team members' do
      it "returns true if user is an auditor" do
        user.update_attribute(:auditor, true)

        features.each do |feature|
          project.project_feature.update_attribute("#{feature}_access_level".to_sym, ProjectFeature::PRIVATE)
          expect(project.feature_available?(:issues, user)).to eq(true)
        end
      end
    end
  end

  describe 'project visibility changes' do
    using RSpec::Parameterized::TableSyntax

    before do
      allow(project).to receive(:maintaining_elasticsearch?).and_return(true)
    end

    where(:feature, :worker_expected) do
      'issues'          | true
      'wiki'            | false
      'builds'          | false
      'merge_requests'  | false
      'repository'      | false
      'pages'           | false
    end

    with_them do
      it 're-indexes project and project associations on update' do
        expect(project).to receive(:maintain_elasticsearch_update)

        if worker_expected
          expect(ElasticAssociationIndexerWorker).to receive(:perform_async).with('Project', project.id, ['issues'])
        else
          expect(ElasticAssociationIndexerWorker).not_to receive(:perform_async)
        end

        project.project_feature.update_attribute("#{feature}_access_level".to_sym, ProjectFeature::PRIVATE)
      end
    end
  end
end
