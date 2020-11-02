import * as types from './mutation_types';

export default {
  [types.REQUEST_METRIC_IMAGES](state) {
    state.isLoadingMetricImages = true;
  },
  [types.RECEIVE_METRIC_IMAGES_SUCCESS](state, images) {
    if (images) {
      state.metricImages = images;
    }

    state.isLoadingMetricImages = false;
  },
  [types.RECEIVE_METRIC_IMAGES_ERROR](state) {
    state.isLoadingMetricImages = false;
  },
  [types.REQUEST_METRIC_UPLOAD](state) {
    state.isUploadingImage = true;
  },
  [types.RECEIVE_METRIC_UPLOAD_SUCCESS](state, image) {
    if (image) {
      state.metricImages.push(image);
    }

    state.isUploadingImage = false;
  },
  [types.RECEIVE_METRIC_UPLOAD_ERROR](state) {
    state.isUploadingImage = false;
  },
};
