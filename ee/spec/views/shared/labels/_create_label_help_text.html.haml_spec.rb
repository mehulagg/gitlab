# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'app/views/shared/labels/_create_label_help_text.html.haml' do
  include ApplicationHelper

  shared_examples 'scoped labels' do
    context 'when license has scoped labels feature' do
      before do
        stub_licensed_features(scoped_labels: true)
      end

      it 'displays scoped labels hint' do
        render 'shared/labels/create_label_help_text'

        expect(rendered).to have_content 'scoped label'
      end
    end

    context 'when license does not have scoped labels feature' do
      before do
        stub_licensed_features(scoped_labels: false)
      end

      it 'does not display scoped labels hint' do
        render 'shared/labels/create_label_help_text'

        expect(rendered).not_to have_content 'scoped label'
      end
    end
  end

  context 'for project label' do
    before do
      project = create(:project)
      @label = project.labels.new
    end

    include_examples 'scoped labels'
  end

  context 'for group label' do
    before do
      group = create(:group)
      @label = group.labels.new
    end

    include_examples 'scoped labels'
  end
end
