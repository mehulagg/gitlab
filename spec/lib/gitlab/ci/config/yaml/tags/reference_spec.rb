# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::YAML::Tags::Reference do
  let(:config) { Gitlab::Config::Loader::Yaml.new(yaml).load! }

  describe '.deep_resolve' do
    subject { described_class.deep_resolve(config) }

    before do
      Gitlab::Ci::Config::YAML::Tags.load_custom_tags_into_psych
    end

    context 'with circular references' do
      let(:yaml) do
        <<~YML
        a: !reference [b]
        b: !reference [a]
        YML
      end

      it 'raises CircularReferenceError' do
        expect { subject }.to raise_error Gitlab::Ci::Config::YAML::Tags::CircularReferenceError, '!reference ["b"] is part of a circular chain'
      end
    end

    context 'with nested circular references' do
      let(:yaml) do
        <<~YML
        a: !reference [b, c]
        b:
          c: !reference [d, e, f]
        d:
          e:
            f: !reference [a]
        YML
      end

      it 'raises CircularReferenceError' do
        expect { subject }.to raise_error Gitlab::Ci::Config::YAML::Tags::CircularReferenceError, '!reference ["b", "c"] is part of a circular chain'
      end
    end

    context 'with missing references' do
      let(:yaml) { 'a: !reference [b]' }

      it 'raises MissingReferenceError' do
        expect { subject }.to raise_error Gitlab::Ci::Config::YAML::Tags::MissingReferenceError, '!reference ["b"] could not be found'
      end
    end

    context 'with invalid references' do
      using RSpec::Parameterized::TableSyntax

      where(:yaml, :error_message) do
        'a: !reference'       | '!reference [] is not valid'
        'a: !reference str'   | '!reference "str" is not valid'
        'a: !reference 1'     | '!reference "1" is not valid'
        'a: !reference [1]'   | '!reference [1] is not valid'
      end

      with_them do
        it 'raises an error' do
          expect { subject }.to raise_error Gitlab::Ci::Config::YAML::Tags::NotValidError, error_message
        end
      end
    end

    context 'with referencing array directly' do
      let(:yaml) do
        <<~YML
        .setup:
          script:
            - echo creating environment 1
            - echo creating environment 2

        .teardown:
          script:
            - echo deleting environment 1
            - echo deleting environment 2

        test:
          before_script: !reference [.setup, script]
          script: echo running my own command
          after_script: !reference [.teardown, script]
        YML
      end

      it 'uses the values' do
        expect(subject[:test]).to match({
          script: 'echo running my own command',
          before_script: ['echo creating environment 1', 'echo creating environment 2'],
          after_script: ['echo deleting environment 1', 'echo deleting environment 2']
        })
      end
    end

    context 'with arrays' do
      let(:yaml) do
        <<~YML
        .setup:
          script:
            - echo creating environment 1
            - echo creating environment 2

        .teardown:
          script:
            - echo deleting environment 1
            - echo deleting environment 2

        test:
          script:
            - !reference [.setup, script]
            - echo running my own command
            - !reference [.teardown, script]
        YML
      end

      it 'joins arrays' do
        expect(subject[:test][:script]).to eq(
          [
            ['echo creating environment 1', 'echo creating environment 2'],
            'echo running my own command',
            ['echo deleting environment 1', 'echo deleting environment 2']
          ]
        )
      end
    end

    context 'with nested arrays' do
      let(:yaml) do
        <<~YML
        .setup:
          script:
            - echo creating environment 1
            - echo creating environment 2

        .teardown:
          script:
            - echo deleting environment 1
            - echo deleting environment 2

        .deployment-template:
          script:
            - !reference [.setup, script]
            - echo deploying my changes
            - !reference [.teardown, script]

        test:
          script:
            - echo preparing to deploy
            - !reference [.deployment-template, script]
            - echo deployment finished
        YML
      end

      it 'resolves deeply nested arrays' do
        expect(subject[:test][:script]).to eq(
          [
            "echo preparing to deploy",
            [
              [
                "echo creating environment 1",
                "echo creating environment 2"
              ],
              "echo deploying my changes",
              [
                "echo deleting environment 1",
                "echo deleting environment 2"
              ]
            ],
            "echo deployment finished"
          ]
        )
      end

      context 'with nested arrays' do
        let(:yaml) do
          <<~YML
          test:
            script:
              - echo preparing to deploy
              - !reference [.deployment-template, script]
              - echo deployment finished

          .setup:
            script:
              - echo creating environment 1
              - echo creating environment 2

          .teardown:
            script:
              - echo deleting environment 1
              - echo deleting environment 2

          .deployment-template:
            script:
              - !reference [.setup, script]
              - echo deploying my changes
              - !reference [.teardown, script]
          YML
        end

        it 'resolves deeply nested arrays' do
          expect(subject[:test][:script]).to eq(
            [
              "echo preparing to deploy",
              [
                [
                  "echo creating environment 1",
                  "echo creating environment 2"
                ],
                "echo deploying my changes",
                [
                  "echo deleting environment 1",
                  "echo deleting environment 2"
                ]
              ],
              "echo deployment finished"
            ]
          )
        end
      end
    end

    context 'when referencing hashes' do
      context 'when referencing entire hash' do
        let(:yaml) do
          <<~YML
          .setup:
            variables:
              a: 'a'
              b: 'b'

          test:
            variables: !reference [.setup, variables]
          YML
        end

        it 'copies variables' do
          expect(subject[:test]).to match({ variables: { a: 'a', b: 'b' } })
        end
      end

      context 'when referencing only a hash value' do
        let(:yaml) do
          <<~YML
          .general_setup:
            variables:
              a: 'a'
              b: 'b'

          .deployment_setup:
            variables:
              c: !reference [.general_setup, variables, a]
              d: 'd'

          test:
            variables: !reference [.deployment_setup, variables]
          YML
        end

        it 'copies variables' do
          expect(subject[:test]).to match({ variables: { c: 'a', d: 'd' } })
        end
      end

      context 'when referencing a hash value before its definition' do
        let(:yaml) do
          <<~YML
          test:
            variables: !reference [.deployment_setup, variables]

          .general_setup:
            variables:
              a: 'a'
              b: 'b'

          .deployment_setup:
            variables:
              c: !reference [.general_setup, variables, a]
              d: 'd'
          YML
        end

        it 'copies variables' do
          expect(subject[:test]).to match({ variables: { c: 'a', d: 'd' } })
        end
      end
    end
  end
end
