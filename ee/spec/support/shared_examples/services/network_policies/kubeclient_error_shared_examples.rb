# frozen_string_literal: true

RSpec.shared_examples 'responds to Kubeclient::HttpError' do |kubeclient_method|
  context 'with Kubeclient::HttpError' do
    let(:request_url) { 'https://kubernetes.local' }
    let(:response) {  RestClient::Response.create('', {}, RestClient::Request.new(url: request_url, method: :get)) }

    before do
      allow(kubeclient).to receive(kubeclient_method).and_raise(Kubeclient::HttpError.new(500, 'system failure', response))
    end

    it 'returns error response', :aggregate_failures do
      expect(subject).to be_error
      expect(subject.http_status).to eq(:bad_request)
      expect(subject.message).not_to be_nil
    end

    it 'returns error message without request url' do
      expect(subject.message).not_to include(request_url)
    end
  end
end
