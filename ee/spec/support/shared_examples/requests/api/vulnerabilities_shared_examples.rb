# frozen_string_literal: true

RSpec.shared_examples 'forbids access to vulnerability API endpoint in case of disabled features' do
  context 'when security dashboard feature is not available' do
    before do
      stub_licensed_features(security_dashboard: false)
    end

    it 'responds with 403 Forbidden' do
      subject

      expect(response).to have_gitlab_http_status(:forbidden)
    end
  end
end

RSpec.shared_examples 'responds with "not found" for an unknown vulnerability ID' do
  let(:vulnerability_id) { 0 }

  specify do
    subject

    expect(response).to have_gitlab_http_status(:not_found)
  end
end
