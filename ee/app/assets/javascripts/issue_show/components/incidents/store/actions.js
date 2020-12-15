import { s__ } from '~/locale';
import createFlash from '~/flash';
import * as types from './mutation_types';
import { deleteMetricImage, getMetricImages, uploadMetricImage } from '../service';

export const fetchMetricImages = async ({ state, dispatch }) => {
  dispatch('requestMetricImages');

  const { issueIid, projectId } = state;

  try {
    const response = await getMetricImages({ id: projectId, issueIid });
    dispatch('receiveMetricImagesSuccess', response);
  } catch (error) {
    dispatch('receiveMetricImagesError');
    createFlash({ message: s__('Incidents|There was an issue loading metric images.') });
  }
};

export const requestMetricImages = ({ commit }) => commit(types.REQUEST_METRIC_IMAGES);
export const receiveMetricImagesSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_METRIC_IMAGES_SUCCESS, response);
export const receiveMetricImagesError = ({ commit }) => commit(types.RECEIVE_METRIC_IMAGES_ERROR);

export const uploadImage = async ({ state, dispatch }, { files, url }) => {
  dispatch('requestMetricUpload');

  const { issueIid, projectId } = state;

  try {
    const response = await uploadMetricImage({ file: files.item(0), id: projectId, issueIid, url });
    dispatch('receiveMetricUploadSuccess', response);
  } catch (error) {
    dispatch('receiveMetricUploadError');
    createFlash({ message: s__('Incidents|There was an issue uploading your image.') });
  }
};

export const requestMetricUpload = ({ commit }) => commit(types.REQUEST_METRIC_UPLOAD);
export const receiveMetricUploadSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_METRIC_UPLOAD_SUCCESS, response);
export const receiveMetricUploadError = ({ commit }) => commit(types.RECEIVE_METRIC_UPLOAD_ERROR);

export const deleteImage = async ({ state, dispatch }, imageId) => {
  const { issueIid, projectId } = state;

  try {
    await deleteMetricImage({ imageId, id: projectId, issueIid });
    dispatch('receiveMetricDeleteSuccess', imageId);
  } catch (error) {
    createFlash({ message: s__('Incidents|There was an issue deleting the image.') });
  }
};

export const receiveMetricDeleteSuccess = ({ commit }, imageId) =>
  commit(types.RECEIVE_METRIC_DELETE_SUCCESS, imageId);
