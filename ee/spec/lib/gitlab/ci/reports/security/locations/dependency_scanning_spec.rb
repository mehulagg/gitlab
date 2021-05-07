# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Locations::DependencyScanning do
  let(:params) do
    {
      file_path: 'app/pom.xml',
      package_name: 'io.netty/netty',
      package_version: '1.2.3'
    }
  end

  let(:mandatory_params) { %i[file_path package_name] }
  let(:expected_fingerprint) { Digest::SHA1.hexdigest('app/pom.xml:io.netty/netty') }
  let(:expected_fingerprint_path) { 'pom.xml' }

  it_behaves_like 'vulnerability location'
end
