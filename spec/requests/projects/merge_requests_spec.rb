# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'merge requests actions' do
  let_it_be_with_refind(:project) { create(:project, :repository) }

  let(:user) { project.owner }
  let(:merge_request) { create(:merge_request_with_diffs, target_project: project, source_project: project) }

  before do
    sign_in(user)
  end

  describe 'GET /:namespace/:project/-/merge_requests/:iid' do
    def go(extra_params = {})
      params = {
        namespace_id: project.namespace.to_param,
        project_id: project,
        id: merge_request.iid
      }

      get namespace_project_merge_request_path(params.merge(extra_params))
    end

    describe 'as json' do
      subject { go(format: :json) }

      context 'with caching', :use_clean_rails_memory_store_caching do
        shared_examples_for 'serializes merge request with expected arguments' do
          it 'serializes merge request' do
            expect_next_instance_of(MergeRequestSerializer) do |instance|
              expect(instance).to receive(:represent)
                .with(an_instance_of(MergeRequest), expected_options)
                .and_call_original
            end

            subject
          end
        end

        context 'when the request has not been cached' do
          it_behaves_like 'serializes merge request with expected arguments' do
            let(:expected_options) { { serializer: nil } }
          end
        end

        context 'when the request has already been cached' do
          before do
            go(format: :json)
          end

          it 'does not serialize merge request again' do
            expect_next_instance_of(MergeRequestSerializer) do |instance|
              expect(instance).not_to receive(:represent)
            end

            subject
          end

          context 'with the different pagination option' do
            subject { go(format: :json, serializer: 'sidebar_extras') }

            it_behaves_like 'serializes merge request with expected arguments' do
              let(:expected_options) { { serializer: 'sidebar_extras' } }
            end
          end
        end
      end
    end
  end
end
