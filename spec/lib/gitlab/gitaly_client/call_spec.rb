# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GitalyClient::Call do
  describe '#call', :request_store do
    let(:client) { Gitlab::GitalyClient }
    let(:storage) { 'default' }
    let(:remote_storage) { nil }
    let(:request) { Gitaly::FindLocalBranchesRequest.new }
    let(:rpc) { :find_local_branches }
    let(:service) { :ref_service }
    let(:timeout) { client.long_timeout }

    subject do
      described_class.new(storage, service, rpc, request, remote_storage, timeout).call
    end

    def expect_call_details_to_match(duration_higher_than: 0)
      expect(client.list_call_details.size).to eq(1)
      expect(client.list_call_details.first)
        .to match a_hash_including(feature: "#{service}##{rpc}",
                                   duration: a_value > duration_higher_than,
                                   request: an_instance_of(Hash),
                                   rpc: rpc,
                                   backtrace: an_instance_of(Array))
    end

    context 'RPC stream handling' do
      before do
        allow(client).to receive(:execute) { response }
        allow(Gitlab::PerformanceBar).to receive(:enabled_for_request?) { true }
      end

      context 'when the response is not an enumerator' do
        let(:response) do
          Gitaly::FindLocalBranchesResponse.new
        end

        it 'returns the response' do
          expect(subject).to eq(response)
        end

        it 'stores timings and call details' do
          subject

          expect(client.query_time).to be > 0
          expect_call_details_to_match
        end

        context 'when err' do
          before do
            allow(client).to receive(:execute).and_raise(StandardError)
          end

          it 'stores timings and call details' do
            expect { subject }.to raise_error(StandardError)

            expect(client.query_time).to be > 0
            expect_call_details_to_match
          end
        end
      end

      context 'when the response is an enumerator' do
        let(:response) do
          Enumerator.new do |yielder|
            yielder << 1
            yielder << 2
          end
        end

        it 'returns a consumable enumerator' do
          instrumented_response = subject

          expect(instrumented_response).to be_a(Enumerator)
          expect(instrumented_response.to_a).to eq([1, 2])
        end

        context 'time measurements' do
          let(:response) do
            Enumerator.new do |yielder|
              sleep 0.1
              yielder << 1
              sleep 0.2
              yielder << 2
            end
          end

          it 'records full rpc stream consumption' do
            subject.to_a

            expect(client.query_time).to be > 0.3
            expect_call_details_to_match(duration_higher_than: 0.3)
          end

          it 'records partial rpc stream consumption' do
            subject.first

            expect(client.query_time).to be > 0.1
            expect_call_details_to_match(duration_higher_than: 0.1)
          end

          context 'when err' do
            let(:response) do
              Enumerator.new do |yielder|
                sleep 0.2
                yielder << 1
                raise StandardError
              end
            end

            it 'records partial rpc stream consumption' do
              expect { subject.to_a }.to raise_error(StandardError)

              expect(client.query_time).to be > 0.2
              expect_call_details_to_match(duration_higher_than: 0.2)
            end
          end
        end
      end
    end

    describe 'primary routing' do
      before do
        stubbed_service = double(rpc => true)
        allow(Gitlab::GitalyClient).to receive(:stub).and_return(stubbed_service)
      end

      context 'gitlab_git_env' do
        let(:policy) { 'gitaly-route-repository-accessor-policy' }

        context 'when RequestStore is disabled' do
          it 'does not force-route to primary' do
            subject do |kwargs|
              expect(kwargs[:metadata][policy]).to be_nil
            end
          end
        end

        context 'when RequestStore is enabled without git_env', :request_store do
          it 'does not force-route to primary' do
            subject do |kwargs|
              expect(kwargs[:metadata][policy]).to be_nil
            end
          end

          context 'with repository size RPC' do
            let(:service) { :repository_service }
            let(:rpc) { :repository_size }

            it 'enables force-routing to primary' do
              subject do |kwargs|
                expect(kwargs[:metadata][policy]).to eq('primary-only')
              end
            end
          end
        end

        context 'when RequestStore is enabled with empty git_env', :request_store do
          before do
            Gitlab::SafeRequestStore[:gitlab_git_env] = {}
          end

          it 'disables force-routing to primary' do
            subject do |kwargs|
              expect(kwargs[:metadata][policy]).to be_nil
            end
          end
        end

        context 'when RequestStore is enabled with populated git_env', :request_store do
          before do
            Gitlab::SafeRequestStore[:gitlab_git_env] = {
              "GIT_OBJECT_DIRECTORY_RELATIVE" => "foo/bar"
            }
          end

          it 'enables force-routing to primary' do
            subject do |kwargs|
              expect(kwargs[:metadata][policy]).to eq('primary-only')
            end
          end
        end
      end
    end
  end
end
