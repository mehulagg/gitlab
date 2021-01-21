# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Locations::Dast do
  let(:params) do
    {
      hostname: 'my-app.com',
      method_name: 'GET',
      param: 'X-Content-Type-Options',
      path: '/some/path'
    }
  end

  let(:mandatory_params) { %i[path method_name] }
  let(:expected_fingerprint) { Digest::SHA1.hexdigest('/some/path:GET:X-Content-Type-Options') }
  let(:expected_fingerprint_path) { '/some/path' }

  it_behaves_like 'vulnerability location'
end
