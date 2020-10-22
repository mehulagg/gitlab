# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectPresenter do
  include Gitlab::Routing.url_helpers

  let(:user) { create(:user) }

  describe '#extra_statistics_buttons' do
    let(:project) { create(:project) }
    let(:presenter) { described_class.new(project, current_user: user) }

    it { expect(presenter.extra_statistics_buttons).to be_empty }
  end
end
