# frozen_string_literal: true

RSpec.shared_examples 'restricts modification if referenced by policy' do |modification_type|
  context 'when project has security policies enabled' do
    before do
      allow_next_found_instance_of(dast_profile.class) do |profile|
        allow(profile).to receive(:referenced_in_security_policies).and_return(policy_names)
      end
    end

    context 'when there is no policy that is referencing the profile' do
      let(:policy_names) { [] }

      it 'returns a success status' do
        expect(status).to eq(:success)
      end
    end

    context 'when there is a policy that is referencing the profile' do
      let(:policy_names) { [dast_profile.name] }

      it 'returns an error status' do
        expect(status).to eq(:error)
      end

      it 'populates message' do
        expect(message).to include("Cannot #{modification_type}")
      end
    end
  end
end
