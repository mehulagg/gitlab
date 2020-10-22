# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Audit::Levels::Project do
  describe '#apply' do
    let_it_be(:project) { create(:project) }

    let_it_be(:project_audit_event) { create(:project_audit_event, entity_id: project.id) }

    subject { described_class.new(project: project).apply }

    it 'finds all project events' do
      expect(subject).to contain_exactly(project_audit_event)
    end
  end
end
