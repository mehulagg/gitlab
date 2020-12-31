# frozen_string_literal: true

require 'fast_spec_helper'
require 'rspec-parameterized'

require 'gitlab/danger/title_linting'

RSpec.describe Gitlab::Danger::TitleLinting do
  using RSpec::Parameterized::TableSyntax

  let(:fake_class) { Class.new.extend(described_class) }

  describe '#sanitize_mr_title' do
    where(:mr_title, :expected_mr_title) do
      '`My MR title`' | "\\`My MR title\\`"
      'WIP: My MR title' | 'My MR title'
      'Draft: My MR title' | 'My MR title'
      '(Draft) My MR title' | 'My MR title'
      '[Draft] My MR title' | 'My MR title'
      '[DRAFT] My MR title' | 'My MR title'
      'DRAFT: My MR title' | 'My MR title'
      'DRAFT: `My MR title`' | "\\`My MR title\\`"
    end

    with_them do
      subject { fake_class.sanitize_mr_title(mr_title) }

      it { is_expected.to eq(expected_mr_title) }
    end
  end

  describe '#sanitize_not_ready_syntax' do
    where(:mr_title, :expected_mr_title) do
      'WIP: My MR title' | 'My MR title'
      'Draft: My MR title' | 'My MR title'
      '(Draft) My MR title' | 'My MR title'
      '[Draft] My MR title' | 'My MR title'
      '[DRAFT] My MR title' | 'My MR title'
      'DRAFT: My MR title' | 'My MR title'
    end

    with_them do
      subject { fake_class.sanitize_not_ready_syntax(mr_title) }

      it { is_expected.to eq(expected_mr_title) }
    end
  end

  describe '#draft_title?' do
    it 'returns true for a draft title' do
      expect(fake_class.draft_title?('Draft: My MR title')).to be true
    end

    it 'returns false for non draft title' do
      expect(fake_class.draft_title?('My MR title')).to be false
    end
  end
end
