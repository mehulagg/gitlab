import { member as memberMock } from 'jest/vue_shared/components/members/mock_data';
import { generateBadges } from 'ee/vue_shared/components/members/utils';

describe('Members Utils', () => {
  describe('generateBadges', () => {
    it('has correct properties for each badge', () => {
      const badges = generateBadges(memberMock, true);

      badges.forEach(badge => {
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
    `('returns expected output for "$expected.text" badge', ({ member, expected }) => {
      expect(generateBadges(member, true)).toContainEqual(expect.objectContaining(expected));
    });
  });
});
