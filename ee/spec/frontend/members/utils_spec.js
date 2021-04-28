import { generateBadges, canOverride, parseDataAttributes } from 'ee/members/utils';
import {
  member as memberMock,
  directMember,
  inheritedMember,
  membersJsonString,
  members,
  paginationJsonString,
  pagination,
} from 'jest/members/mock_data';

describe('Members Utils', () => {
  describe('generateBadges', () => {
    it('has correct properties for each badge', () => {
      const badges = generateBadges({
        member: memberMock,
        isCurrentUser: true,
        canManageMembers: true,
      });

      badges.forEach((badge) => {
        expect(badge).toEqual(
          expect.objectContaining({
            show: expect.any(Boolean),
            text: expect.any(String),
            variant: expect.stringMatching(/muted|neutral|info|success|danger|warning/),
          }),
        );
      });
    });

    it.each`
      member                                          | expected
      ${{ ...memberMock, usingLicense: true }}        | ${{ show: true, text: 'Is using seat', variant: 'neutral' }}
      ${{ ...memberMock, groupSso: true }}            | ${{ show: true, text: 'SAML', variant: 'info' }}
      ${{ ...memberMock, groupManagedAccount: true }} | ${{ show: true, text: 'Managed Account', variant: 'info' }}
      ${{ ...memberMock, canOverride: true }}         | ${{ show: true, text: 'LDAP', variant: 'info' }}
    `('returns expected output for "$expected.text" badge', ({ member, expected }) => {
      expect(
        generateBadges({ member, isCurrentUser: true, canManageMembers: true }),
      ).toContainEqual(expect.objectContaining(expected));
    });
  });

  describe('canOverride', () => {
    test.each`
      member                                        | expected
      ${{ ...directMember, canOverride: true }}     | ${true}
      ${{ ...inheritedMember, canOverride: true }}  | ${false}
      ${{ ...directMember, canOverride: false }}    | ${false}
      ${{ ...inheritedMember, canOverride: false }} | ${false}
    `('returns $expected', ({ member, expected }) => {
      expect(canOverride(member)).toBe(expected);
    });
  });

  describe('group member utils', () => {
    describe('parseDataAttributes', () => {
      let el;

      beforeEach(() => {
        el = document.createElement('div');
        el.setAttribute('data-members', membersJsonString);
        el.setAttribute('data-pagination', paginationJsonString);
        el.setAttribute('data-source-id', '234');
        el.setAttribute('data-can-manage-members', 'true');
        el.setAttribute(
          'data-ldap-override-path',
          '/groups/ldap-group/-/group_members/:id/override',
        );
      });

      afterEach(() => {
        el = null;
      });

      it('correctly parses the data attributes', () => {
        expect(parseDataAttributes(el)).toEqual({
          members,
          pagination,
          sourceId: 234,
          canManageMembers: true,
          ldapOverridePath: '/groups/ldap-group/-/group_members/:id/override',
        });
      });
    });
  });
});
