# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::DistinctCount do
  context 'counting distinct users' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }

    let(:column) { :creator_id }

    before do
      create_list(:project, 3, creator: user)
      create_list(:project, 1, creator: other_user)
    end

    subject(:count) { described_class.new(Project, :creator_id).count(from: Project.minimum(:creator_id), to: Project.maximum(:creator_id) + 1) }

    it { is_expected.to eq(2) }

    context 'when the fully qualified column is given' do
      let(:column) { 'projects.creator_id' }

      it { is_expected.to eq(2) }
    end

    context 'when AR attribute is given' do
      let(:column) { Project.arel_table[:creator_id] }

      it { is_expected.to eq(2) }
    end

    context 'when null values are present' do
      before do
        create_list(:project, 2).each { |p| p.update_column(:creator_id, nil) }
      end

      it { is_expected.to eq(2) }
    end
  end
end
