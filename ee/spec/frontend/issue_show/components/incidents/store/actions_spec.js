import { createLocalVue } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import Vuex from 'vuex';
import testAction from 'helpers/vuex_action_helper';
import createStore from 'ee/issue_show/components/incidents/store';
import * as actions from 'ee/issue_show/components/incidents/store/actions';
import * as types from 'ee/issue_show/components/incidents/store/mutation_types';
import { issueMetricImagesPath } from 'ee/issue_show/components/incidents/service';
import createFlash from '~/flash';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

jest.mock('~/flash');

const defaultState = {
  issueIid: 1,
  projectId: '2',
};

const localVue = createLocalVue();
localVue.use(Vuex);

const fetchGroupsUrl = Api.buildUrl(issueMetricImagesPath)
  .replace(':id', encodeURIComponent(defaultState.projectId))
  .replace(':issue_iid', encodeURIComponent(defaultState.issueIid));

const files = [{ file_path: 'test', filename: 'hello', id: 5, url: null }];

describe('Metrics tab store actions', () => {
  let mockAdapter;
  let store;
  let state;

  beforeEach(() => {
    store = createStore(defaultState);
    state = store.state;
    mockAdapter = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAdapter.reset();
    createFlash.mockClear();
  });

  describe('fetching metric images', () => {
    it('should call success action when fetching metric images', () => {
      mockAdapter.onGet(fetchGroupsUrl).reply(httpStatus.OK, files);

      testAction(
        actions.fetchMetricImages,
        null,
        state,
        [],
        [
          { type: 'requestMetricImages' },
          {
            type: 'receiveMetricImagesSuccess',
            payload: convertObjectPropsToCamelCase(files, { deep: true }),
          },
        ],
      );
    });

    it('should call error action when fetching metric images with an error', done => {
      mockAdapter.onGet(fetchGroupsUrl).reply(httpStatus.INTERNAL_SERVER_ERROR, files);

      testAction(
        actions.fetchMetricImages,
        null,
        state,
        [],
        [{ type: 'requestMetricImages' }, { type: 'receiveMetricImagesError' }],
        () => {
          expect(createFlash).toHaveBeenCalled();
          done();
        },
      );
    });

    it('should call request mutation successfully', () => {
      testAction(actions.requestMetricImages, null, state, [{ type: types.REQUEST_METRIC_IMAGES }]);
    });

    it('should call success mutation successfully', () => {
      testAction(actions.receiveMetricImagesSuccess, files, state, [
        { type: types.RECEIVE_METRIC_IMAGES_SUCCESS, payload: files },
      ]);
    });

    it('should call error mutation successfully', () => {
      testAction(actions.receiveMetricImagesError, null, state, [
        { type: types.RECEIVE_METRIC_IMAGES_ERROR },
      ]);
    });
  });

  describe('uploading metric images', () => {
    const payload = {
      // mock the FileList api
      files: {
        item() {
          return files[0];
        },
      },
      url: 'test_url',
    };

    it('should call success action when uploading an image', () => {
      mockAdapter.onPost(fetchGroupsUrl).reply(httpStatus.OK, files[0]);

      testAction(
        actions.uploadImage,
        payload,
        state,
        [],
        [
          { type: 'requestMetricUpload' },
          { type: 'receiveMetricUploadSuccess', payload: convertObjectPropsToCamelCase(files[0]) },
        ],
      );
    });

    it('should call error action when failing to upload an image', done => {
      mockAdapter.onPost(fetchGroupsUrl).reply(httpStatus.INTERNAL_SERVER_ERROR);

      testAction(
        actions.uploadImage,
        payload,
        state,
        [],
        [{ type: 'requestMetricUpload' }, { type: 'receiveMetricUploadError' }],
        () => {
          expect(createFlash).toHaveBeenCalled();
          done();
        },
      );
    });

    it('should call request mutation successfully', () => {
      testAction(actions.requestMetricUpload, null, state, [{ type: types.REQUEST_METRIC_UPLOAD }]);
    });

    it('should call success mutation successfully', () => {
      testAction(actions.receiveMetricUploadSuccess, files, state, [
        { type: types.RECEIVE_METRIC_UPLOAD_SUCCESS, payload: files },
      ]);
    });

    it('should call error mutation successfully', () => {
      testAction(actions.receiveMetricUploadError, null, state, [
        { type: types.RECEIVE_METRIC_UPLOAD_ERROR },
      ]);
    });
  });
});
