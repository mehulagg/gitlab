import { REPORT_TYPES } from 'ee/vulnerabilities/components/generic_report/types/constants';
import { isSupportedReportType } from 'ee/vulnerabilities/components/generic_report/types/utils';

describe('ee/vulnerabilities/components/generic_report/types/utils', () => {
  describe('isSupportedReportType', () => {
    it.each(REPORT_TYPES)('returns "true" if the given type is "%s"', (reportType) => {
      expect(isSupportedReportType(reportType)).toBe(true);
    });

    it('returns "false" if the given type is not supported', () => {
      expect(isSupportedReportType('this-type-does-not-exist')).toBe(false);
    });
  });
});
