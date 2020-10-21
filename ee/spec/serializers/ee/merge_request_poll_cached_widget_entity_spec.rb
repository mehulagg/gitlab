# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestPollCachedWidgetEntity do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:resource) { create(:merge_request, source_project: project, target_project: project) }
  let_it_be(:user) { create(:user) }

  let(:request) { double('request', current_user: user, project: project) }

  subject { described_class.new(resource, request: request).as_json }

  it 'includes docs path for merge trains' do
    is_expected.to include(:merge_train_when_pipeline_succeeds_docs_path)
  end

  it 'includes policy violation status' do
    is_expected.to include(:policy_violation)
  end

  it 'includes missing security scan types' do
    is_expected.to include(:missing_security_scan_types)
  end
end
