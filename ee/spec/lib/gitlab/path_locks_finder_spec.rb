# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::PathLocksFinder do
  let_it_be(:project) { create :project }
  let_it_be(:user) { create :user }
  let_it_be(:lock1) { create(:path_lock, project: project, path: 'app') }
  let_it_be(:lock2) { create :path_lock, project: project, path: 'lib/gitlab/repo.rb' }

  let(:finder) { described_class.new(project) }

  it "returns correct lock information" do
    expect(finder.find('app')).to eq(lock1)
    expect(finder.find('app/models/project.rb')).to eq(lock1)
    expect(finder.find('lib')).to be_falsey
    expect(finder.find('lib/gitlab/repo.rb')).to eq(lock2)
  end

  describe '#preload_for_paths' do
    it 'does not perform N + 1 requests' do
      finder.preload_for_paths(['app/models/project.rb', 'lib/gitlab/repo.rb'])

      count = ActiveRecord::QueryRecorder.new do
        expect(finder.find_by_path('app')).to eq(lock1)
        expect(finder.find_by_path('app/models/project.rb')).to eq(lock1)
        expect(finder.find_by_path('lib')).to be_falsey
        expect(finder.find_by_path('lib/gitlab/repo.rb')).to eq(lock2)
      end.count

      expect(count).to eq(1)
    end
  end
end
