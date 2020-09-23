# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TemplateFinder do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project) { create(:project) }

  let(:params) { {} }

  let(:fake_template_source) { double(::Gitlab::CustomFileTemplates) }
  let(:custom_template) { OpenStruct.new(key: 'foo', name: 'foo', category: nil, content: 'Template') }
  let(:custom_templates) { [custom_template] }

  subject(:finder) { described_class.build(type, project, params) }

  describe '#execute' do
    where(:type, :expected_template_finder) do
      :dockerfiles    | ::Gitlab::Template::CustomDockerfileTemplate
      :gitignores     | ::Gitlab::Template::CustomGitignoreTemplate
      :gitlab_ci_ymls | ::Gitlab::Template::CustomGitlabCiYmlTemplate
    end

    with_them do
      subject(:result) { finder.execute }

      before do
        expect(Gitlab::CustomFileTemplates)
          .to receive(:new)
          .with(expected_template_finder, project)
          .and_return(fake_template_source)

        allow(fake_template_source)
          .to receive(:find)
          .with(custom_template.key)
          .and_return(custom_template)

        allow(fake_template_source)
          .to receive(:all)
          .and_return(custom_templates)
      end

      context 'custom templates enabled' do
        before do
          allow(fake_template_source).to receive(:enabled?).and_return(true)
        end

        it 'returns custom templates' do
          is_expected.to include(custom_template)
        end

        context 'a custom template is specified by name' do
          let(:params) { { name: custom_template.key } }

          it 'returns the custom template if its name is specified' do
            is_expected.to eq(custom_template)
          end
        end
      end

      context 'custom templates disabled' do
        before do
          allow(fake_template_source).to receive(:enabled?).and_return(false)
        end

        it 'does not return any custom templates' do
          is_expected.not_to include(custom_template)
        end
      end
    end
  end
end
