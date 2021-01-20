# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::YAML::Tags do
  let(:config) { Gitlab::Config::Loader::Yaml.new(yaml).load! }

  describe '#to_hash' do
    subject { described_class.new(config).to_hash }

    let(:yaml) do
      <<~YML
      a: !reference [b, c]
      b:
        c: 1
      d: !flatten
        - 1
        - [2]
        - [3, [4]]
      YML
    end

    context 'when tags are not loaded into Psych' do
      it { is_expected.to match({ a: ['b', 'c'], b: { c: 1 }, d: [1, [2], [3, [4]]] }) }
    end

    context 'when tags are loaded into Psych' do
      before do
        described_class.load_custom_tags_into_psych
      end

      it { is_expected.to match({ a: 1, b: { c: 1 }, d: [1, 2, 3, 4] }) }

      context 'where referencing and flatting deep nested arrays' do
        let(:yaml_templates) do
          <<~YML
          .job-1:
            script:
              - echo doing step 1 of job 1
              - echo doing step 2 of job 1

          .job-2:
            script:
              - echo doing step 1 of job 2
              - !reference [.job-1, script]
              - echo doing step 2 of job 2

          .job-3:
            script: !flatten
              - echo doing step 1 of job 3
              - !reference [.job-2, script]
              - echo doing step 2 of job 3
          YML
        end

        let(:job_yaml) do
          <<~YML
          test:
            script: !flatten
              - echo preparing to test
              - !reference [.job-3, script]
              - echo test finished
          YML
        end

        shared_examples 'expands references' do
          it 'expands and flattens the references' do
            is_expected.to match({
              '.job-1': {
                script: [
                  'echo doing step 1 of job 1',
                  'echo doing step 2 of job 1'
                ]
              },
              '.job-2': {
                script: [
                  'echo doing step 1 of job 2',
                  [
                    'echo doing step 1 of job 1',
                    'echo doing step 2 of job 1'
                  ],
                  'echo doing step 2 of job 2'
                ]
              },
              '.job-3': {
                script: [
                  'echo doing step 1 of job 3',
                  'echo doing step 1 of job 2',
                  'echo doing step 1 of job 1',
                  'echo doing step 2 of job 1',
                  'echo doing step 2 of job 2',
                  'echo doing step 2 of job 3'
                ]
              },
              test: {
                script: [
                  'echo preparing to test',
                  'echo doing step 1 of job 3',
                  'echo doing step 1 of job 2',
                  'echo doing step 1 of job 1',
                  'echo doing step 2 of job 1',
                  'echo doing step 2 of job 2',
                  'echo doing step 2 of job 3',
                  'echo test finished'
                ]
              }
            })
          end
        end

        context 'when templates are defined before the job' do
          let(:yaml) do
            <<~YML
            #{yaml_templates}

            #{job_yaml}
            YML
          end

          it_behaves_like 'expands references'
        end

        context 'when templates are defined after the job' do
          let(:yaml) do
            <<~YML
            #{job_yaml}

            #{yaml_templates}
            YML
          end

          it_behaves_like 'expands references'
        end
      end

      context 'when using circular references and flatten' do
        let(:yaml) do
          <<~YML
          job-1:
            script:
              - echo doing step 1 of job 1
              - !reference [job-3, script]

          job-2:
            script:
              - echo doing step 1 of job 2
              - !reference [job-1, script]

          job-3:
            script: !flatten
              - echo doing step 1 of job 3
              - !reference [job-2, script]
          YML
        end

        it 'raises an exception about circular references' do
          expect { subject }.to raise_error Gitlab::Ci::Config::YAML::Tags::CircularReferenceError, '!reference ["job-3", "script"] is part of a circular chain'
        end
      end
    end
  end
end
