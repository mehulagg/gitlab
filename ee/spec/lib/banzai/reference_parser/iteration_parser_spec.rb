# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Banzai::ReferenceParser::IterationParser do
  include ReferenceParserHelpers

  let(:project) { create(:project, :public) }
  let(:user) { create(:user) }
  let(:iteration) { create(:iteration, :skip_project_validation, project: project) }
  subject { described_class.new(Banzai::RenderContext.new(project, user)) }

  let(:link) { empty_html_link }

  describe '#nodes_visible_to_user' do
    context 'when the link has a data-iteration attribute' do
      before do
        link['data-iteration'] = iteration.id.to_s
      end

      it_behaves_like "referenced feature visibility", "issues", "merge_requests"
    end
  end

  describe '#referenced_by' do
    describe 'when the link has a data-iteration attribute' do
      context 'using an existing iteration ID' do
        it 'returns an Array of iterations' do
          link['data-iteration'] = iteration.id.to_s

          expect(subject.referenced_by([link])).to eq([iteration])
        end
      end

      context 'using a non-existing iteration ID' do
        it 'returns an empty Array' do
          link['data-iteration'] = ''

          expect(subject.referenced_by([link])).to eq([])
        end
      end
    end
  end
end
