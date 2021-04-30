import {
  REPORT_TYPE_SAST,
  REPORT_TYPE_SECRET_DETECTION,
  REPORT_FILE_TYPES,
} from '~/vue_shared/security_reports/constants';
import { extractSecurityReportArtifactsFromMr } from '~/vue_shared/security_reports/utils';
import {
  securityReportDownloadPathsQueryResponse,
  sastArtifacts,
  secretDetectionArtifacts,
  archiveArtifacts,
  traceArtifacts,
  metadataArtifacts,
} from './mock_data';

describe('extractSecurityReportArtifactsFromMr', () => {
  it.each`
    reportTypes                                         | expectedArtifacts
    ${[]}                                               | ${[]}
    ${['foo']}                                          | ${[]}
    ${[REPORT_TYPE_SAST]}                               | ${sastArtifacts}
    ${[REPORT_TYPE_SECRET_DETECTION]}                   | ${secretDetectionArtifacts}
    ${[REPORT_TYPE_SAST, REPORT_TYPE_SECRET_DETECTION]} | ${[...secretDetectionArtifacts, ...sastArtifacts]}
    ${[REPORT_FILE_TYPES.ARCHIVE]}                      | ${archiveArtifacts}
    ${[REPORT_FILE_TYPES.TRACE]}                        | ${traceArtifacts}
    ${[REPORT_FILE_TYPES.METADATA]}                     | ${metadataArtifacts}
  `(
    'returns the expected artifacts given report types $reportTypes',
    ({ reportTypes, expectedArtifacts }) => {
      expect(
        extractSecurityReportArtifactsFromMr(reportTypes, securityReportDownloadPathsQueryResponse),
      ).toEqual(expectedArtifacts);
    },
  );
});
