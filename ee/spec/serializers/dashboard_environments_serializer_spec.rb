# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DashboardEnvironmentsSerializer do
  describe '.represent' do
    it 'returns an empty array when there are no projects' do
      current_user = create(:user)
      projects = []

      result = described_class.new(current_user: current_user).represent(projects)

      expect(result).to eq([])
    end

    it 'includes project attributes' do
      current_user = create(:user)
      project = create(:project)
      create(:environment, project: project, state: :available)
      projects = [project]

      result = described_class.new(current_user: current_user).represent(projects)

      expect(result.first.keys.sort).to eq([:avatar_url, :environments, :id, :name, :namespace, :remove_path, :web_url])
    end
  end
end
