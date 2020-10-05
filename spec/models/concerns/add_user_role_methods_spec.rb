# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddUserRoleMethods do
  let(:klass) do
    Class.new do
      include ::AddUserRoleMethods

      def add_user(user, role, param1: nil, param2: nil)
        # This method intentionally left blank.
      end
    end
  end

  shared_context 'call add_user_role_methods_for with' do |*params|
    before do
      klass.instance_eval do
        add_user_role_methods_for(*params)
      end
    end
  end

  describe '.add_user_role_methods_for' do
    shared_examples 'defined convenience methods' do |role_methods|
      role_methods.each do |role_method|
        it { is_expected.to respond_to role_method }
      end
    end

    subject { klass.new }

    context 'with array of roles' do
      include_context 'call add_user_role_methods_for with', %i[abc def]

      include_examples 'defined convenience methods', %w[add_abc add_def]
    end

    context 'with multiple role parameters' do
      include_context 'call add_user_role_methods_for with', :abc, :def

      include_examples 'defined convenience methods', %w[add_abc add_def]
    end

    context 'with string roles' do
      include_context 'call add_user_role_methods_for with', 'abc', 'def'

      include_examples 'defined convenience methods', %w[add_abc add_def]
    end
  end

  context 'with convience methods specified' do
    let(:obj) { klass.new }
    let(:user) { build :user }

    include_context 'call add_user_role_methods_for with', :abc

    it 'will pass through parameters to #add_user' do
      expect(obj).to receive(:add_user).with(user, :abc, param1: 'hello world')

      obj.add_abc(user, param1: 'hello world')
    end
  end
end
