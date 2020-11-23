# frozen_string_literal: true

require 'spec_helper'

class Implementation
  include ::Pages::LegacyStorageLease

  attr_reader :project

  def initialize(project)
    @project = project
  end

  def execute
    with_exclusive_lease do
      execute_unsafe
    end
  end

  def execute_unsafe; end
end

RSpec.describe ::Pages::LegacyStorageLease do
  let(:project) { create(:project) }
  let(:service) { Implementation.new(project) }

  it 'allows method to be executed' do
    expect(service).to receive :execute_unsafe

    service.execute
  end

  context 'when another service holds the lease for the same project' do
    around do |example|
      Implementation.new(project).with_exclusive_lease do
        example.run
      end
    end

    it 'raises an exception' do
      expect(service).not_to receive(:execute_unsafe)

      expect { service.execute }.to raise_error(::Pages::ExclusiveLeaseTaken)
    end
  end

  context 'when another service holds the lease for the different project' do
    around do |example|
      Implementation.new(create(:project)).with_exclusive_lease do
        example.run
      end
    end

    it 'allows method to be executed' do
      expect(service).to receive :execute_unsafe

      service.execute
    end
  end
end
