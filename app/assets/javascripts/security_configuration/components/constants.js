import { s__ } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';

export const SAST_MANAGE = s__('SecurityConfiguration|Configure via Merge Request');
export const SAST_NAME = s__('SecurityConfiguration|Static Application Security Testing (SAST)');
export const SAST_DESCRIPTION = s__(
  'SecurityConfiguration|Analyze your source code for known vulnerabilities.',
);
export const SAST_LINK = helpPagePath('user/application_security/sast/index');

export const DAST_MANAGE = s__('SecurityConfiguration|Available with upgrade or free trial');
export const DAST_NAME = s__('SecurityConfiguration|Dynamic Application Security Testing (DAST)');
export const DAST_DESCRIPTION = s__(
  'SecurityConfiguration|Analyze a review version of your web application.',
);
export const DAST_LINK = helpPagePath('user/application_security/dast/index');

export const SECRET_DETECTION_MANAGE = s__(
  'SecurityConfiguration|Available with upgrade or free trial',
);
export const SECRET_DETECTION_NAME = s__('SecurityConfiguration|Secret Detection');
export const SECRET_DETECTION_DESCRIPTION = s__(
  'SecurityConfiguration|Analyze your source code and git history for secrets.',
);
export const SECRET_DETECTION_LINK = helpPagePath(
  'user/application_security/secret_detection/index',
);

export const DEPENDENCY_SCANNING_MANAGE = s__(
  'SecurityConfiguration|Available with upgrade or free trial',
);
export const DEPENDENCY_SCANNING_NAME = s__('SecurityConfiguration|Dependency Scanning');
export const DEPENDENCY_SCANNING_DESCRIPTION = s__(
  'SecurityConfiguration|Analyze your dependencies for known vulnerabilities.',
);
export const DEPENDENCY_SCANNING_LINK = helpPagePath(
  'user/application_security/dependency_scanning/index',
);

export const CONTAINER_SCANNING_MANAGE = s__(
  'SecurityConfiguration|Available with upgrade or free trial',
);
export const CONTAINER_SCANNING_NAME = s__('SecurityConfiguration|Container Scanning');
export const CONTAINER_SCANNING_DESCRIPTION = s__(
  'SecurityConfiguration|Check your Docker images for known vulnerabilities.',
);
export const CONTAINER_SCANNING_LINK = helpPagePath(
  'user/application_security/container_scanning/index',
);

export const COVERAGE_FUZZING_MANAGE = s__(
  'SecurityConfiguration|Available with upgrade or free trial',
);
export const COVERAGE_FUZZING_NAME = s__('SecurityConfiguration|Coverage Fuzzing');
export const COVERAGE_FUZZING_DESCRIPTION = s__(
  'SecurityConfiguration|Find bugs in your code with coverage-guided fuzzing.',
);
export const COVERAGE_FUZZING_LINK = helpPagePath(
  'user/application_security/coverage_fuzzing/index',
);

export const LICENSE_COMPLIANCE_MANAGE = s__(
  'SecurityConfiguration|Available with upgrade or free trial',
);
export const LICENSE_COMPLIANCE_NAME = s__('SecurityConfiguration|License Compliance');
export const LICENSE_COMPLIANCE_DESCRIPTION = s__(
  'SecurityConfiguration|Search your project dependencies for their licenses and apply policies.',
);
export const LICENSE_COMPLIANCE_LINK = helpPagePath('user/compliance/license_compliance/index');
export const REPORT_TYPE_SAST = 'sast';
export const REPORT_TYPE_DAST = 'dast';
export const REPORT_TYPE_SECRET_DETECTION = 'secret_detection';
export const REPORT_TYPE_DEPENDENCY_SCANNING = 'dependency_scanning';
export const REPORT_TYPE_CONTAINER_SCANNING = 'container_scanning';
export const REPORT_TYPE_COVERAGE_FUZZING = 'coverage_fuzzing';
export const REPORT_TYPE_LICENSE_COMPLIANCE = 'license_compliance';