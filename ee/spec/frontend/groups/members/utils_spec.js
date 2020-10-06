import { membersJsonString, membersParsed } from 'jest/groups/members/mock_data';
import { parseDataAttributes } from 'ee/groups/members/utils';

describe('group member utils', () => {
  describe('parseDataAttributes', () => {
    let el;

    beforeEach(() => {
      el = document.createElement('div');
      el.setAttribute('data-members', membersJsonString);
      el.setAttribute('data-group-id', '234');
      el.setAttribute('data-ldap-override-path', '/groups/ldap-group/-/group_members/:id/override');

      document.body.appendChild(el);
    });

    afterEach(() => {
      document.body.innerHTML = '';
      el = null;
    });

    it('correctly parses the data attributes', () => {
      expect(parseDataAttributes(el)).toEqual({
        members: membersParsed,
        sourceId: 234,
        ldapOverridePath: '/groups/ldap-group/-/group_members/:id/override',
      });
    });
  });
});
