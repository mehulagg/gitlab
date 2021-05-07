import { REPORT_STATUS } from 'ee/dependencies/store/modules/list/constants';
import * as getters from 'ee/dependencies/store/modules/list/getters';
import { TEST_HOST } from 'helpers/test_constants';
import { getDateInPast } from '~/lib/utils/datetime_utility';

describe('Dependencies getters', () => {
  describe.each`
    getterName             | reportStatus                    | outcome
    ${'isJobNotSetUp'}     | ${REPORT_STATUS.jobNotSetUp}    | ${true}
    ${'isJobNotSetUp'}     | ${REPORT_STATUS.ok}             | ${false}
    ${'isJobFailed'}       | ${REPORT_STATUS.jobFailed}      | ${true}
    ${'isJobFailed'}       | ${REPORT_STATUS.noDependencies} | ${false}
    ${'isJobFailed'}       | ${REPORT_STATUS.ok}             | ${false}
    ${'hasNoDependencies'} | ${REPORT_STATUS.ok}             | ${false}
    ${'hasNoDependencies'} | ${REPORT_STATUS.noDependencies} | ${true}
    ${'isIncomplete'}      | ${REPORT_STATUS.incomplete}     | ${true}
    ${'isIncomplete'}      | ${REPORT_STATUS.ok}             | ${false}
  `('$getterName when report status is $reportStatus', ({ getterName, reportStatus, outcome }) => {
    it(`returns ${outcome}`, () => {
      expect(
        getters[getterName]({
          reportInfo: {
            status: reportStatus,
          },
        }),
      ).toBe(outcome);
    });
  });

  describe('downloadEndpoint', () => {
    it('should return download endpoint', () => {
      const endpoint = `${TEST_HOST}/dependencies`;
      expect(getters.downloadEndpoint({ endpoint })).toBe(endpoint);
    });
  });

  describe('generatedAtTimeAgo', () => {
    it.each`
      daysAgo | outcome
      ${1}    | ${'1 day ago'}
      ${2}    | ${'2 days ago'}
      ${7}    | ${'1 week ago'}
    `(
      'should return "$outcome" when "generatedAt" was $daysAgo days ago',
      ({ daysAgo, outcome }) => {
        const generatedAt = getDateInPast(new Date(), daysAgo);

        expect(getters.generatedAtTimeAgo({ reportInfo: { generatedAt } })).toBe(outcome);
      },
    );

    it('should return an empty string when "generatedAt" is not given', () => {
      expect(getters.generatedAtTimeAgo({ reportInfo: {} })).toBe('');
    });
  });
});
