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
      let(:total_repository_size_excess) { 100 }
      let(:additional_purchased_storage) { 50.megabytes }

      before do
        allow(namespace).to receive(:total_repository_size_excess).and_return(total_repository_size_excess)
      end

      include_examples 'size checker for snippet'
    end

    context 'when snippet without a project' do
      let(:total_repository_size_excess) { 0 }
      let(:additional_purchased_storage) { 0 }

      include_examples 'size checker for snippet'
    end
  end
end
