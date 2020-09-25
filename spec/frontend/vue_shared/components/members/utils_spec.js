import { datePropValidator } from '~/vue_shared/components/members/utils';

describe('members utils', () => {
  describe('datePropValidator', () => {
    it.each`
      propValue       | expected
      ${'2020-03-15'} | ${true}
      ${null}         | ${true}
      ${{}}           | ${false}
      ${[]}           | ${false}
      ${1}            | ${false}
    `('returns $expected when prop value is $propValue', ({ propValue, expected }) => {
      expect(datePropValidator(propValue)).toBe(expected);
    });
  });
});
