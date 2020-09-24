# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Sources::Project do
  describe 'Relations' do
    it { is_expected.to belong_to(:pipeline).required }
    it { is_expected.to belong_to(:source_project).required }
  end

  describe 'Validations' do
    let!(:project_source) { create(:ci_sources_project) }

    it { is_expected.to validate_uniqueness_of(:pipeline_id).scoped_to(:source_project_id) }
  end
end
