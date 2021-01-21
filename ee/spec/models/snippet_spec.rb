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

      let(:namespace) { build(:namespace) }
      let(:project) { build(:project, namespace: namespace) }

      include_examples 'size checker for snippet'
    end

    context 'when snippet without a project' do
      let(:namespace) { nil }

      include_examples 'size checker for snippet'
    end
  end
end
