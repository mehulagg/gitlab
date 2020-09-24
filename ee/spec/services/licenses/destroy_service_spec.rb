# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Licenses::DestroyService do
  let(:license) { create(:license) }

  let_it_be(:user) { create(:admin) }

  def destroy_with(user)
    described_class.new(license, user).execute
  end

  it 'destroys a license' do
    destroy_with(user)

    expect(License.where(id: license.id)).not_to exist
  end

  it 'raises an error if license is nil' do
    expect { described_class.new(nil, user).execute }.to raise_error ActiveRecord::RecordNotFound
  end

  it 'raises an error if the user is not an admin' do
    expect { destroy_with(create(:user)) }.to raise_error Gitlab::Access::AccessDeniedError
  end
end
