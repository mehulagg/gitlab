import { parseData } from 'ee/subscriptions/buy_minutes/utils';
import { mockCiMinutesPlans, mockParsedCiMinutesPlans } from './mock_data';

describe('utils', () => {
  describe('#parseData', () => {
    describe.each`
      ciMinutesPlans        | parsedCiMinutesPlans        | throws
      ${'[]'}               | ${[]}                       | ${false}
      ${'null'}             | ${{}}                       | ${false}
      ${mockCiMinutesPlans} | ${mockParsedCiMinutesPlans} | ${false}
      ${''}                 | ${{}}                       | ${true}
    `('parameter decoding', ({ ciMinutesPlans, parsedCiMinutesPlans, throws }) => {
      it(`decodes ${ciMinutesPlans} to ${parsedCiMinutesPlans}`, () => {
        if (throws) {
          expect(() => {
            parseData({ ciMinutesPlans });
          }).toThrow();
        } else {
          const result = parseData({ ciMinutesPlans });
          expect(result.ciMinutesPlans).toEqual(parsedCiMinutesPlans);
        }
      });
    });
  });
});
