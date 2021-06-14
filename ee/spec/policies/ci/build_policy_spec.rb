# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::BuildPolicy do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, group: group) }

  let(:user) { create(:user) }
  let(:pipeline) { create(:ci_empty_pipeline, project: project, sha: 'b83d6e391c22777fca1ed3012fce84f633d7fed0') }

  describe '#update_build?' do
    let(:environment) { create(:environment, project: project, name: 'production') }
    let(:build) { create(:ee_ci_build, pipeline: pipeline, environment: 'production', ref: 'development') }

    subject { user.can?(:update_build, build) }

    it_behaves_like 'protected environments access', direct_access: true
  end
end
