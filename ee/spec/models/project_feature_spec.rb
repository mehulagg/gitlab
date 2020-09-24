# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectFeature do
  let(:project) { create(:project) }
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
end
