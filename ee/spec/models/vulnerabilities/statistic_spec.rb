# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Statistic do
  describe 'associations' do
    it { is_expected.to belong_to(:project).required(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:critical).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:high).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:medium).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:low).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:unknown).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:info).is_greater_than_or_equal_to(0) }
    it { is_expected.to define_enum_for(:letter_grade).with_values(%i(a b c d f)) }
  end

  describe '.before_save' do
    describe '#assign_letter_grade' do
      let(:statistic) { build(:vulnerability_statistic, letter_grade: nil, critical: 5) }

      subject(:save_statistic) { statistic.save! }

      it 'assigns the letter_grade' do
        expect { save_statistic }.to change { statistic.letter_grade }.from(nil).to('f')
      end
    end
  end

  describe '.letter_grade_for' do
    subject { described_class.letter_grade_for(object) }

    context 'when the given object is an instance of Vulnerabilities::Statistic' do
      let(:object) { build(:vulnerability_statistic, critical: 1) }

      it { is_expected.to eq(4) }
    end

    context 'when the given object is a Hash' do
      let(:object) { { 'high' => 1 } }

      it { is_expected.to eq(3) }
    end
  end
end
