import * as getters from 'ee/license_compliance/store/modules/list/getters';
import { REPORT_STATUS } from 'ee/license_compliance/store/modules/list/constants';
import { LICENSE_APPROVAL_CLASSIFICATION } from 'ee/vue_shared/license_compliance/constants';

describe('Licenses getters', () => {
  describe.each`
    getterName       | reportStatus                 | outcome
    ${'isJobSetUp'}  | ${REPORT_STATUS.jobNotSetUp} | ${false}
    ${'isJobSetUp'}  | ${REPORT_STATUS.ok}          | ${true}
    ${'isJobFailed'} | ${REPORT_STATUS.jobFailed}   | ${true}
    ${'isJobFailed'} | ${REPORT_STATUS.noLicenses}  | ${true}
    ${'isJobFailed'} | ${REPORT_STATUS.incomplete}  | ${true}
    ${'isJobFailed'} | ${REPORT_STATUS.ok}          | ${false}
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

  describe('hasPolicyViolations', () => {
    it('returns true when there are policy violations', () => {
      expect(
        getters.hasPolicyViolations({
          licenses: [{ classification: LICENSE_APPROVAL_CLASSIFICATION.DENIED }, {}],
        }),
      ).toBe(true);
    });

    it('returns false when there are policy violations', () => {
      expect(
        getters.hasPolicyViolations({
          licenses: [{ classification: LICENSE_APPROVAL_CLASSIFICATION.ALLOWED }, {}],
        }),
      ).toBe(false);
    });
  });
});
