# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::ExportCsvService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:requirement) { create(:requirement, state: :opened, project: project) }

  subject { described_class.new(RequirementsManagement::Requirement.all, project) }

  before do
    stub_licensed_features(requirements: true)
  end

  it 'renders csv to string' do
    expect(subject.csv_data).to be_a String
  end

  describe '#email' do
    it 'emails csv' do
      expect { subject.email(user) }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
    end

    it 'renders with a target filesize' do
      expect_next_instance_of(CsvBuilder) do |csv_builder|
        expect(csv_builder).to receive(:render).with(described_class::TARGET_FILESIZE).once
      end

      subject.email(user)
    end
  end

  def csv
    CSV.parse(subject.csv_data, headers: true)
  end

  context 'includes' do
    before do
      create(
        :test_report, requirement: requirement,
        state: :failed, build: nil,
        created_at: DateTime.new(2015, 4, 2, 2, 1, 0)
      )
      create(
        :test_report, requirement: requirement,
        state: :passed, build: nil,
        created_at: DateTime.new(2015, 4, 3, 2, 1, 0)
      )
    end

    it 'includes the columns required for import' do
      expect(csv.headers).to include('Title', 'Description')
    end

    specify 'iid' do
      expect(csv[0]['Requirement ID']).to eq requirement.iid.to_s
    end

    specify 'title' do
      expect(csv[0]['Title']).to eq requirement.title
    end

    specify 'description' do
      expect(csv[0]['Description']).to eq requirement.description
    end

    specify 'author username' do
      expect(csv[0]['Author Username']).to eq requirement.author.username
    end

    specify 'latest test report state' do
      expect(csv[0]['Latest Test Report State']).to eq "Passed"
    end

    specify 'latest test report created at' do
      expect(csv[0]['Latest Test Report Created At (UTC)']).to eq '2015-04-03 02:01:00 UTC'
    end
  end
end
