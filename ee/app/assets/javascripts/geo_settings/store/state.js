import { DEFAULT_TIMEOUT, DEFAULT_ALLOWED_IP, FORM_VALIDATION_FIELDS } from '../constants';

export default () => ({
  isLoading: false,
  timeout: DEFAULT_TIMEOUT,
  allowedIp: DEFAULT_ALLOWED_IP,
  formErrors: Object.keys(FORM_VALIDATION_FIELDS)
    .map(key => FORM_VALIDATION_FIELDS[key])
    .reduce((acc, cur) => ({ ...acc, [cur]: '' }), {}),
});
