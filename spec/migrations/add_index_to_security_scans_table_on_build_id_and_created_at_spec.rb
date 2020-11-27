# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20201127104228_add_index_to_security_scans_on_build_id_and_created_at.rb')

RSpec.describe AddIndexToSecurityScansOnBuildIdAndCreatedAt do
  let(:migration) { described_class.new }

  describe '#up' do
    it 'creates temporary partial index on type' do
      expect { migration.up }.to change { migration.index_exists?(:security_scans, %i[build_id created_at], name: 'index_security_scans_on_build_id_and_created_at') }.from(false).to(true)
    end
  end

  describe '#down' do
    it 'removes temporary partial index on type' do
      migration.up

      expect { migration.down }.to change { migration.index_exists?(:security_scans, %i[build_id created_at], name: 'index_security_scans_on_build_id_and_created_at') }.from(true).to(false)
    end
  end
end
