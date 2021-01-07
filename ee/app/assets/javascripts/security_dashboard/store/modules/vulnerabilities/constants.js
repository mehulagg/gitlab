import httpStatusCodes from '~/lib/utils/http_status';

export {
  CRITICAL,
  HIGH,
  MEDIUM,
  LOW,
  INFO,
  UNKNOWN,
  SEVERITIES,
} from '~/vulnerabilities/constants';

export const LOADING_VULNERABILITIES_ERROR_CODES = {
  UNAUTHORIZED: httpStatusCodes.UNAUTHORIZED,
  FORBIDDEN: httpStatusCodes.FORBIDDEN,
};
