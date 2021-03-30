import { REPORT_TYPES } from 'ee/vulnerabilities/components/generic_report/types/constants';
import { isValidReportType } from 'ee/vulnerabilities/components/generic_report/types/utils';

describe('ee/vulnerabilities/components/generic_report/types/utils', () => {
  describe('isValidReportType', () => {
    it.each(REPORT_TYPES)('returns "true" if the given type is a "%s"', (reportType) => {
      expect(isValidReportType(reportType)).toBe(true);
    });

    it('returns "false" if the given type is not supported', () => {
      expect(isValidReportType('this-type-does-not-exist')).toBe(false);
    });
  });
});
