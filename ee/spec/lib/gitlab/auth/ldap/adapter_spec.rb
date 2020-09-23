# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::Ldap::Adapter do
  include LdapHelpers

  let(:adapter) { ldap_adapter('ldapmain') }

  it 'includes the EE module' do
    expect(described_class).to include_module(EE::Gitlab::Auth::Ldap::Adapter)
  end

  describe '#groups' do
    before do
      stub_ldap_config(
        group_base: 'ou=groups,dc=example,dc=com',
        active_directory: false
      )
    end

    it 'searches with the proper options' do
      # Requires this expectation style to match the filter
      expect(adapter).to receive(:ldap_search) do |arg|
        expect(arg[:filter].to_s).to eq('(cn=*)')
        expect(arg[:base]).to eq('ou=groups,dc=example,dc=com')
        expect(arg[:attributes]).to match(%w(dn cn memberuid member submember uniquemember memberof))
      end.and_return({})

      adapter.groups
    end

    it 'returns a group object if search returns a result' do
      entry = ldap_group_entry(%w(uid=john uid=mary), cn: 'group1')
      allow(adapter).to receive(:ldap_search).and_return([entry])

      results = adapter.groups('group1')

      expect(results.first).to be_a(EE::Gitlab::Auth::Ldap::Group)
      expect(results.first.cn).to eq('group1')
      expect(results.first.member_dns).to match_array(%w(uid=john uid=mary))
    end
  end

  describe '#filter_search' do
    before do
      stub_ldap_config(
        base: 'ou=my_groups,dc=example,dc=com'
      )
    end

    it 'searches with the proper options' do
      expect(adapter).to receive(:ldap_search) do |arg|
        expect(arg[:filter].to_s).to eq('(ou=people)')
        expect(arg[:base]).to eq('ou=my_groups,dc=example,dc=com')
      end.and_return({})

      adapter.filter_search('(ou=people)')
    end

    it 'errors out with an invalid filter' do
      expect { adapter.filter_search(')(') }
        .to raise_error(Net::LDAP::FilterSyntaxInvalidError, 'Invalid filter syntax.')
    end
  end

  describe '#user_by_certificate_assertion' do
    let(:certificate_assertion) { 'certificate_assertion' }

    subject { adapter.user_by_certificate_assertion(certificate_assertion) }

    context 'return value' do
      let(:entry) { ldap_user_entry('john') }

      before do
        allow(adapter).to receive(:ldap_search).and_return([entry])
      end

      it 'returns a person object' do
        expect(subject).to be_a(::EE::Gitlab::Auth::Ldap::Person)
      end

      it 'returns correct attributes' do
        result = subject

        expect(result.uid).to eq('john')
        expect(result.dn).to eq('uid=john,ou=users,dc=example,dc=com')
      end
    end

    it 'searches with the proper options' do
      expect(adapter).to receive(:ldap_search).with(
        { attributes: array_including('dn', 'cn', 'mail', 'uid', 'userid'),
          base: 'dc=example,dc=com',
          filter: Net::LDAP::Filter.ex(
            'userCertificate:certificateExactMatch', certificate_assertion) }
      ).and_return({})

      subject
    end
  end
end
