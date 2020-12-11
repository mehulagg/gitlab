# frozen_string_literal: true

require 'fast_spec_helper'
require_relative 'danger_spec_helper'

require 'gitlab/danger/merge_request_linter'

RSpec.describe Gitlab::Danger::MergeRequestLinter do
  let(:mr_class) do
    Struct.new(:message, :sha, :diff_parent)
  end

  let(:mr_title) { 'A B ' + 'C' }
  let(:mr_prefix) { 'merge request title' }
  let(:merge_request) { mr_class.new(mr_title, anything, anything) }

  describe '#lint_subject' do
    subject(:mr_linter) { described_class.new(merge_request) }

    shared_examples 'a valid mr title' do
      it 'does not have any problem' do
        mr_linter.lint_subject(mr_prefix)

        expect(mr_linter.problems).to be_empty
      end
    end

    context 'when subject valid' do
      it_behaves_like 'a valid mr title'
    end

    context 'when it is too long' do
      let(:mr_title) { 'A B ' + 'C' * described_class::MAX_LINE_LENGTH }

      it 'adds a problem' do
        expect(mr_linter).to receive(:add_problem).with(:subject_too_long, mr_prefix)

        mr_linter.lint_subject(mr_prefix)
      end
    end

    context "when line has #{described_class::RUN_AS_IF_FOSS}" do
      let(:mr_title) { described_class::RUN_AS_IF_FOSS + ' A B ' + 'C' * (described_class::MAX_LINE_LENGTH - 5) }

      it_behaves_like 'a valid mr title'
    end

    context "when line has [#{described_class::RUN_AS_IF_FOSS}]" do
      let(:mr_title) { "[#{described_class::RUN_AS_IF_FOSS}]" + ' A B ' + 'C' * (described_class::MAX_LINE_LENGTH - 5) }

      it_behaves_like 'a valid mr title'
    end
  end
end
