# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::BaseService do
  include ProjectForksHelper

  let_it_be(:project) { create(:project, :repository) }

  let(:title) { 'Awesome merge_request' }
  let(:params) do
    {
      title: title,
      description: 'please fix',
      source_branch: 'feature',
      target_branch: 'master'
    }
  end

  subject { MergeRequests::CreateService.new(project: project, current_user: project.owner, params: params) }

  describe '#filter_params' do
    let(:params_filtering_service) { double(:params_filtering_service) }

    context 'filter users and groups' do
      before do
        allow(subject).to receive(:execute_hooks)
      end

      it 'calls ParamsFilteringService' do
        expect(ApprovalRules::ParamsFilteringService).to receive(:new).with(
          an_instance_of(MergeRequest),
          project.owner,
          params
        ).and_return(params_filtering_service)
        expect(params_filtering_service).to receive(:execute).and_return(params)

        subject.execute
      end
    end
  end
end
