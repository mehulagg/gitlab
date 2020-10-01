# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippet do
  describe '#repository_size_checker' do
    let(:checker) { subject.repository_size_checker }
    let(:current_size) { 60 }

    before do
      allow(subject.repository).to receive(:size).and_return(current_size)
    end

    context 'when snippet belongs to a project' do
      subject { build(:project_snippet, project: project) }

      let(:namespace) { build(:namespace, additional_purchased_storage_size: 50) }
      let(:project) { build(:project, namespace: namespace) }

      before do
        allow(namespace).to receive(:total_repository_size_excess).and_return(100)
      end

      it 'sets up size checker', :aggregate_failures do
        expect(checker.current_size).to eq(current_size.megabytes)
        expect(checker.limit).to eq(Gitlab::CurrentSettings.snippet_size_limit)
        expect(checker.total_repository_size_excess).to eq(100)
        expect(checker.additional_purchased_storage).to eq(50.megabytes)
        expect(checker.enabled?).to be_truthy
      end
    end

    include_examples 'size checker for snippet without project'
  end
end
