# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Net::HTTP do
  describe '#proxy_user' do
    subject { described_class.new('hostname.example').proxy_user }

    it { is_expected.to eq(nil) }

    context 'with http_proxy env' do
      before do
        stub_env('http_proxy', 'http://proxy.example:8000')
      end

      it { is_expected.to eq(nil) }

      context 'and user:password authentication' do
        before do
          stub_env('http_proxy', 'http://Y%5CX:R%25S%5D%20%3FX@proxy.example:8000')
        end

        specify do
          if Net::HTTP::ENVIRONMENT_VARIABLE_IS_MULTIUSER_SAFE
            # linux, freebsd, darwin are considered as multi user safe environment variable platforms
            # See https://github.com/ruby/net-http/blob/v0.1.1/lib/net/http.rb#L1174-L1178
            expect(subject).to eq('Y\\X')
          else
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end

  describe '#proxy_pass' do
    subject { described_class.new('hostname.example').proxy_pass }

    it { is_expected.to eq(nil) }

    context 'with http_proxy env' do
      before do
        stub_env('http_proxy', 'http://proxy.example:8000')
      end

      it { is_expected.to eq(nil) }

      context 'and user:password authentication' do
        before do
          stub_env('http_proxy', 'http://Y%5CX:R%25S%5D%20%3FX@proxy.example:8000')
        end

        specify do
          if Net::HTTP::ENVIRONMENT_VARIABLE_IS_MULTIUSER_SAFE
            # linux, freebsd, darwin are considered as multi user safe environment variable platforms
            # See https://github.com/ruby/net-http/blob/v0.1.1/lib/net/http.rb#L1174-L1178
            expect(subject).to eq('R%S] ?X')
          else
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end
end
