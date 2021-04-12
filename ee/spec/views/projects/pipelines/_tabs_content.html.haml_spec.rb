# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/pipelines/_tabs_content' do
  let_it_be(:user) { create(:user) }

  let(:pipeline) { create(:ci_pipeline).present(current_user: user) }
  let(:locals) { { pipeline: pipeline, project: pipeline.project } }

  before do
    allow(pipeline).to receive(:expose_security_dashboard?).and_return(true)
  end

  it 'rendering the Vulnerability Findings API endpoint path' do
    render partial: 'projects/pipelines/tabs_content', locals: locals

    expect(rendered).to include "projects/#{pipeline.project_id}/vulnerability_findings"
  end
end
