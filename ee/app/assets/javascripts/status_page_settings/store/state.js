import { parseBoolean } from '~/lib/utils/common_utils';

export default (initialState = {}) => ({
  enabled: parseBoolean(initialState.enabled) || false,
  url: initialState.url || '',
  bucketName: initialState.bucketName || '',
  region: initialState.region || '',
  awsAccessKey: initialState.awsAccessKey || '',
  awsSecretKey: initialState.awsSecretKey || '',
  operationsSettingsEndpoint: initialState.operationsSettingsEndpoint || '',
  loading: false,
});
