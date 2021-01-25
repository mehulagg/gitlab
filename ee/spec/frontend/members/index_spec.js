import { membersJsonString } from 'jest/members/mock_data';
import { initMembersApp } from '~/members/index';

describe('initMembersApp', () => {
  let el;
  let vm;

  const createVm = () => {
    vm = initMembersApp(el, {});
  };

  beforeEach(() => {
    el = document.createElement('div');
    el.setAttribute('data-members', membersJsonString);
    el.setAttribute('data-source-id', '234');
    el.setAttribute('data-member-path', '/groups/foo-bar/-/group_members/:id');
    el.setAttribute('data-ldap-override-path', '/groups/ldap-group/-/group_members/:id/override');
  });

  afterEach(() => {
    el = null;
  });

  it('sets `ldapOverridePath` in Vuex store', () => {
    createVm();

    expect(vm.$store.state.ldapOverridePath).toBe(
      '/groups/ldap-group/-/group_members/:id/override',
    );
  });
});
