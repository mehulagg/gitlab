# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectRepositoryStorageMove, type: :model do
  it_behaves_like 'repository storage moveable', :project, ProjectUpdateRepositoryStorageWorker
end
