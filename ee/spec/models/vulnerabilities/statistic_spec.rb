# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Statistic do
  describe 'associations' do
    it { is_expected.to belong_to(:project).required(true) }
    it { is_expected.to belong_to(:pipeline).required(false) }
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

  describe '.set_latest_pipeline_with' do
    let_it_be(:pipeline) { create(:ci_pipeline) }
    let_it_be(:project) { pipeline.project }

    subject(:set_latest_pipeline) { described_class.set_latest_pipeline_with(pipeline) }

    context 'when there is already a vulnerability_statistic record available for the project of given pipeline' do
      let(:vulnerability_statistic) { create(:vulnerability_statistic, project: project) }

      it 'updates the `latest_pipeline_id` attribute of the existing record' do
        expect { set_latest_pipeline }.to change { vulnerability_statistic.reload.pipeline }.from(nil).to(pipeline)
      end
    end

    context 'when there is no vulnerability_statistic record available for the project of given pipeline' do
      it 'creates a new record with the `latest_pipeline_id` attribute is set' do
        expect { set_latest_pipeline }.to change { project.reload.vulnerability_statistic }.from(nil).to(an_instance_of(described_class))
                                      .and change { project.vulnerability_statistic&.pipeline }.from(nil).to(pipeline)
      end
    end
  end
end
