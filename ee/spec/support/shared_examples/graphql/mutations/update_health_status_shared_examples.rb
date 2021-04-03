# frozen_string_literal: true

RSpec.shared_examples 'updating health status' do
  let(:resource_klass) { resource.class }
  let(:mutated_resource) { subject[resource_klass.underscore.to_sym] }
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }
  let(:params) do
    { iid: resource.iid, health_status: resource_klass.health_statuses[:at_risk] }.tap do |args|
      if resource.is_a?(Epic)
        args[:group_path] = resource.resource_parent.full_path
      else
        args[:project_path] = resource.resource_parent.full_path
      end
    end
  end

  subject { mutation.resolve(**params) }

  context 'when the user has permission' do
    before do
      resource.resource_parent.add_developer(user)
    end

    context 'and issuable_heath_status feature is disabled' do
      before do
        stub_licensed_features(issuable_health_status: false, epics: true)
      end

      it 'does not update health status' do
        expect do
          subject
          resource.reload
        end.not_to change { resource.health_status }
      end
    end

    context 'and issuable_health_status feature is enabled' do
      before do
        stub_licensed_features(issuable_health_status: true, epics: true)
      end

      it 'updates health status' do
        expect(mutated_resource.health_status).to eq('at_risk')
      end
    end
  end
end
