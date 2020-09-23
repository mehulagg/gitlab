import * as types from './mutation_types';

export default {
  [types.SET_STATUS_PAGE_ENABLED](state, enabled) {
    state.enabled = enabled;
  },
  [types.SET_STATUS_PAGE_URL](state, url) {
    state.url = url;
  },
  [types.SET_BUCKET_NAME](state, bucketName) {
    state.bucketName = bucketName;
  },
  [types.SET_REGION](state, region) {
    state.region = region;
  },
  [types.SET_ACCESS_KEY_ID](state, awsAccessKey) {
    state.awsAccessKey = awsAccessKey;
  },
  [types.SET_SECRET_ACCESS_KEY](state, awsSecretKey) {
    state.awsSecretKey = awsSecretKey;
  },
  [types.LOADING](state, loading) {
    state.loading = loading;
  },
};
