# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyListEntity do
  it_behaves_like 'report list' do
    let(:name) { :dependencies }
    let(:collection) { [build(:dependency)] }
    let(:no_items_status) { :no_dependencies }
  end
end
