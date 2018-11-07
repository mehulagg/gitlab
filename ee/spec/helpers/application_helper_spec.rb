# frozen_string_literal: true

require 'spec_helper'

describe ApplicationHelper do
  include EE::GeoHelpers

  describe '#read_only_message' do
    context 'when not in a Geo secondary' do
      it 'returns a fallback message if database is readonly' do
        expect(Gitlab::Database).to receive(:read_only?) { true }

        expect(helper.read_only_message).to match('You are on a read-only GitLab instance')
      end

      it 'returns nil when database is not read_only' do
        expect(helper.read_only_message).to be_nil
      end
    end

    context 'when in a Geo Secondary' do
      before do
        stub_current_geo_node(create(:geo_node))
      end

      context 'when there is no Geo Primary node configured' do
        it 'returns a read-only Geo message without a link to a primary node' do
          expect(helper.read_only_message).to match(/If you want to make changes, you must visit this page on the .*primary node/)
          expect(helper.read_only_message).not_to include('http://')
        end
      end

      context 'when there is a Geo Primary node configured' do
        let!(:geo_primary) { create(:geo_node, :primary) }

        it 'returns a read-only Geo message with a link to primary node' do
          expect(helper.read_only_message).to match(/If you want to make changes, you must visit this page on the .*primary node/)
          expect(helper.read_only_message).to include(geo_primary.url)
        end

        it 'returns a limited actions message when @limited_actions_message is true' do
          assign(:limited_actions_message, true)

          expect(helper.read_only_message).to match(/You may be able to make a limited amount of changes or perform a limited amount of actions on this page/)
          expect(helper.read_only_message).not_to include('http://')
        end
      end
    end
  end

  describe '#autocomplete_data_sources' do
    def expect_autocomplete_data_sources(object, noteable_type, source_keys)
      sources = helper.autocomplete_data_sources(object, noteable_type)
      expect(sources.keys).to match_array(source_keys)
      sources.keys.each do |key|
        expect(sources[key]).not_to be_nil
      end
    end

    context 'group' do
      let(:object) { create(:group) }
      let(:noteable_type) { Epic }

      it 'returns paths for autocomplete_sources_controller' do
        expect_autocomplete_data_sources(object, noteable_type, [:members, :labels, :epics, :commands])
      end
    end

    context 'project' do
      let(:object) { create(:project) }
      let(:noteable_type) { Issue }

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'returns paths for autocomplete_sources_controller for personal projects' do
          expect_autocomplete_data_sources(object, noteable_type, [:members, :issues, :mergeRequests, :labels, :milestones, :commands, :snippets])
        end

        it 'returns paths for autocomplete_sources_controller including epics for group projects' do
          object.update(group: create(:group))

          expect_autocomplete_data_sources(object, noteable_type, [:members, :issues, :mergeRequests, :labels, :milestones, :commands, :snippets, :epics])
        end
      end

      context 'when epics are disabled' do
        it 'returns paths for autocomplete_sources_controller' do
          expect_autocomplete_data_sources(object, noteable_type, [:members, :issues, :mergeRequests, :labels, :milestones, :commands, :snippets])
        end
      end
    end
  end

  context 'when both CE and EE has partials with the same name' do
    let(:partial) { 'shared/issuable/form/default_templates' }
    let(:view) { 'projects/merge_requests/show' }
    let(:project) { build_stubbed(:project) }

    describe '#render_ce' do
      before do
        helper.instance_variable_set(:@project, project)

        allow(project).to receive(:feature_available?)
      end

      it 'renders the CE partial' do
        helper.render_ce(partial)

        expect(project).not_to receive(:feature_available?)
      end
    end

    describe '#find_ce_template' do
      let(:expected_partial_path) do
        "app/views/#{File.dirname(partial)}/_#{File.basename(partial)}.html.haml"
      end
      let(:expected_view_path) do
        "app/views/#{File.dirname(view)}/#{File.basename(view)}.html.haml"
      end

      it 'finds the CE partial' do
        ce_partial = helper.find_ce_template(partial)

        expect(ce_partial.inspect).to eq(expected_partial_path)

        # And it could still find the EE partial
        ee_partial = helper.lookup_context.find(partial, [], true)
        expect(ee_partial.inspect).to eq("ee/#{expected_partial_path}")
      end

      it 'finds the CE view' do
        ce_view = helper.find_ce_template(view)

        expect(ce_view.inspect).to eq(expected_view_path)

        # And it could still find the EE view
        ee_view = helper.lookup_context.find(view, [], false)
        expect(ee_view.inspect).to eq("ee/#{expected_view_path}")
      end
    end
  end
end
