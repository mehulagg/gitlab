import { s__ } from '~/locale';
import createFlash from '~/flash';
import * as types from './mutation_types';
import { getMetricImages, uploadMetricImage } from '../service';

export const fetchMetricImages = async ({ state, commit }) => {
  commit(types.REQUEST_METRIC_IMAGES);

  const { issueIid, projectId } = state;

  try {
    const response = await getMetricImages({ id: projectId, issueIid });
    commit(types.RECEIVE_METRIC_IMAGES_SUCCESS, response);
  } catch (error) {
    commit(types.RECEIVE_METRIC_IMAGES_ERROR);
    createFlash({ message: s__('Incidents|There was an issue loading metric images.') });
  }
};

export const uploadImage = async ({ state, commit }, { files, url }) => {
  commit(types.REQUEST_METRIC_UPLOAD);

  const { issueIid, projectId } = state;

  try {
    const response = await uploadMetricImage({ file: files.item(0), id: projectId, issueIid, url });
    commit(types.RECEIVE_METRIC_UPLOAD_SUCCESS, response);
  } catch (error) {
    commit(types.RECEIVE_METRIC_UPLOAD_ERROR);
    createFlash({ message: s__('Incidents|There was an issue uploading your image.') });
  }
};

export const setInitialData = ({ commit }, data) => {
  commit(types.SET_INITIAL_DATA, data);
};
