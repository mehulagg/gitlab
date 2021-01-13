import * as types from 'ee/issue_show/components/incidents/store/mutation_types';
import mutations from 'ee/issue_show/components/incidents/store/mutations';
import { cloneDeep } from 'lodash';
import { initialData } from '../mock_data';

const defaultState = {
  metricImages: [],
  isLoadingMetricImages: false,
  isUploadingImage: false,
};

const testImages = [
  { filename: 'test.filename', id: 0, filePath: 'test/file/path', url: null },
  { filename: 'second.filename', id: 1, filePath: 'second/file/path', url: 'test/url' },
];

describe('Metric images mutations', () => {
  let state;

  const createState = (customState = {}) => {
    state = {
      ...cloneDeep(defaultState),
      ...customState,
    };
  };

  beforeEach(() => {
    createState();
  });

  describe('REQUEST_METRIC_IMAGES', () => {
    beforeEach(() => {
      mutations[types.REQUEST_METRIC_IMAGES](state);
    });

    it('should set the loading state', () => {
      expect(state.isLoadingMetricImages).toBe(true);
    });
  });

  describe('RECEIVE_METRIC_IMAGES_SUCCESS', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_METRIC_IMAGES_SUCCESS](state, testImages);
    });

    it('should unset the loading state', () => {
      expect(state.isLoadingMetricImages).toBe(false);
    });

    it('should set the metric images', () => {
      expect(state.metricImages).toEqual(testImages);
    });
  });

  describe('RECEIVE_METRIC_IMAGES_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_METRIC_IMAGES_ERROR](state);
    });

    it('should unset the loading state', () => {
      expect(state.isLoadingMetricImages).toBe(false);
    });
  });

  describe('REQUEST_METRIC_UPLOAD', () => {
    beforeEach(() => {
      mutations[types.REQUEST_METRIC_UPLOAD](state);
    });

    it('should set the loading state', () => {
      expect(state.isUploadingImage).toBe(true);
    });
  });

  describe('RECEIVE_METRIC_UPLOAD_SUCCESS', () => {
    const initialImage = testImages[0];
    const newImage = testImages[1];

    beforeEach(() => {
      createState({ metricImages: [initialImage] });
      mutations[types.RECEIVE_METRIC_UPLOAD_SUCCESS](state, newImage);
    });

    it('should unset the loading state', () => {
      expect(state.isUploadingImage).toBe(false);
    });

    it('should add the new metric image after the existing one', () => {
      expect(state.metricImages).toMatchObject([initialImage, newImage]);
    });
  });

  describe('RECEIVE_METRIC_UPLOAD_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_METRIC_UPLOAD_ERROR](state);
    });

    it('should unset the loading state', () => {
      expect(state.isUploadingImage).toBe(false);
    });
  });

  describe('SET_INITIAL_DATA', () => {
    beforeEach(() => {
      mutations[types.SET_INITIAL_DATA](state, initialData);
    });

    it('should unset the loading state', () => {
      expect(state.issueIid).toBe(initialData.issueIid);
      expect(state.projectId).toBe(initialData.projectId);
    });
  });
});
