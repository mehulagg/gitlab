import {
  REPORT_TYPES,
  REPORT_TYPE_LIST,
} from 'ee/vulnerabilities/components/generic_report/types/constants';
import {
  isSupportedReportType,
  isListType,
} from 'ee/vulnerabilities/components/generic_report/types/utils';

describe('ee/vulnerabilities/components/generic_report/types/utils', () => {
  describe('isSupportedReportType', () => {
    it.each(REPORT_TYPES)('returns "true" if the given type is a "%s"', (reportType) => {
      expect(isSupportedReportType(reportType)).toBe(true);
    });

    it('returns "false" if the given type is not supported', () => {
      expect(isSupportedReportType('this-type-does-not-exist')).toBe(false);
    });
  });

  describe('isListType', () => {
    it('returns "true" if the given type is a "list"', () => {
      expect(isListType(REPORT_TYPE_LIST)).toBe(true);
    });

    it.each(REPORT_TYPES.filter((t) => t !== REPORT_TYPE_LIST))(
      'returns "false" is the given type is a "%s"',
      (nonListType) => {
        expect(isListType(nonListType)).toBe(false);
      },
    );
  });
});
