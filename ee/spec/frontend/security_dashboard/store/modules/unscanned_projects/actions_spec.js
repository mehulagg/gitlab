import MockAdapter from 'axios-mock-adapter';

import * as actions from 'ee/security_dashboard/store/modules/unscanned_projects/actions';
import * as types from 'ee/security_dashboard/store/modules/unscanned_projects/mutation_types';
import createState from 'ee/security_dashboard/store/modules/unscanned_projects/state';
import testAction from 'helpers/vuex_action_helper';

import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/flash');

describe('EE Unscanned Projects actions', () => {
  const mockEndpoint = 'mock-list-endpoint';
  const mockResponse = [{ key_foo: 'valueFoo' }];

  let mockAxios;
  let state;

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
    state = createState();
  });

  afterEach(() => {
    mockAxios.restore();
  });

  describe('fetchUnscannedProjects', () => {
    it('calls the unscanned projects endpoint and transforms the response keys into camel case', () => {
      mockAxios.onGet(mockEndpoint).replyOnce(200, mockResponse);

      const mockResponseCamelCased = [{ keyFoo: 'valueFoo' }];

      return testAction(
        actions.fetchUnscannedProjects,
        mockEndpoint,
        state,
        [],
        [
          { type: 'requestUnscannedProjects' },
          { type: 'receiveUnscannedProjectsSuccess', payload: mockResponseCamelCased },
        ],
      );
    });

    it('handles an API error by dispatching "receiveUnscannedProjectsError"', () => {
      mockAxios.onGet(mockEndpoint).replyOnce(500);

      return testAction(
        actions.fetchUnscannedProjects,
        mockEndpoint,
        state,
        [],
        [{ type: 'requestUnscannedProjects' }, { type: 'receiveUnscannedProjectsError' }],
      );
    });
  });

  describe('requestUnscannedProjects', () => {
    it('commits the REQUEST_UNSCANNED_PROJECTS mutations', () =>
      testAction(
        actions.requestUnscannedProjects,
        null,
        state,
        [
          {
            type: types.REQUEST_UNSCANNED_PROJECTS,
          },
        ],
        [],
      ));
  });

  describe('receiveUnscannedProjectsSuccess', () => {
    it('commits the RECEIVE_UNSCANNED_PROJECTS_SUCCESS mutation', () => {
      const projects = [];

      return testAction(
        actions.receiveUnscannedProjectsSuccess,
        projects,
        state,
        [
          {
            type: types.RECEIVE_UNSCANNED_PROJECTS_SUCCESS,
            payload: projects,
          },
        ],
        [],
      );
    });
  });

  describe('receiveUnscannedProjectsError', () => {
    it('commits the RECEIVE_UNSCANNED_PROJECTS_ERROR mutation', () => {
      const projects = [];

      return testAction(
        actions.receiveUnscannedProjectsError,
        projects,
        state,
        [
          {
            type: types.RECEIVE_UNSCANNED_PROJECTS_ERROR,
          },
        ],
        [],
      );
    });

    it('creates a flash error message', () => {
      const mockDispatchContext = { dispatch: () => {}, commit: () => {}, state };

      actions.receiveUnscannedProjectsError(mockDispatchContext);

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith({
        message: 'Unable to fetch unscanned projects',
      });
    });
  });
});
