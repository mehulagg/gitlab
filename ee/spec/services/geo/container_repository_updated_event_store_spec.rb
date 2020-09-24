# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::ContainerRepositoryUpdatedEventStore do
  include EE::GeoHelpers

  let_it_be(:secondary_node) { create(:geo_node) }

  let(:container_repository) { create :container_repository }

  subject { described_class.new(container_repository) }

  describe '#create' do
    it_behaves_like 'a Geo event store', Geo::ContainerRepositoryUpdatedEvent

    context 'when running on a primary node' do
      before do
        stub_primary_node
      end

      it 'refers to a container repository' do
        subject.create!

        expect(Geo::ContainerRepositoryUpdatedEvent.last).to have_attributes(container_repository: container_repository)
      end

      it 'logs an error message when event creation fail' do
        subject = described_class.new(nil)

        expected_message = {
          class: described_class.name,
          host: 'localhost',
          message: 'Container repository updated event could not be created',
          error: "Validation failed: Container repository can't be blank"
        }

        expect(Gitlab::Geo::Logger).to receive(:error).with(expected_message).and_call_original

        subject.create!
      end
    end
  end
end
