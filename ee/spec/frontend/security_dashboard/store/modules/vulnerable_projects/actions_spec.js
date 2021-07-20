import MockAdapter from 'axios-mock-adapter';

import * as actions from 'ee/security_dashboard/store/modules/vulnerable_projects/actions';
import * as types from 'ee/security_dashboard/store/modules/vulnerable_projects/mutation_types';
import createState from 'ee/security_dashboard/store/modules/vulnerable_projects/state';
import testAction from 'helpers/vuex_action_helper';

import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/flash');

describe('Vulnerable Projects actions', () => {
  const mockEndpoint = 'mock-list-endpoint';
  const mockResponse = [{ key_foo: 'valueFoo' }];

  let mockAxios;
  let mockDispatchContext;
  let state;

  beforeEach(() => {
    mockDispatchContext = { dispatch: () => {}, commit: () => {}, state };
    state = createState();
  });

  describe('fetchProjects', () => {
    beforeEach(() => {
      mockAxios = new MockAdapter(axios);
    });

    afterEach(() => {
      mockAxios.restore();
    });

    it('calls the vulnerable projects endpoint and transforms the response keys into camel case', () => {
      mockAxios.onGet(mockEndpoint).replyOnce(200, mockResponse);

      const mockResponseCamelCased = [{ keyFoo: 'valueFoo' }];

      return testAction(
        actions.fetchProjects,
        mockEndpoint,
        state,
        [],
        [
          { type: 'requestProjects' },
          { type: 'receiveProjectsSuccess', payload: mockResponseCamelCased },
        ],
      );
    });

    it('handles an API error by dispatching "receiveProjectsError"', () => {
      mockAxios.onGet(mockEndpoint).replyOnce(500);

      return testAction(
        actions.fetchProjects,
        mockEndpoint,
        state,
        [],
        [{ type: 'requestProjects' }, { type: 'receiveProjectsError' }],
      );
    });
  });

  describe('request projects', () => {
    it('commits the SET_LOADING and SET_HAS_ERROR mutations', () =>
      testAction(
        actions.requestProjects,
        null,
        state,
        [
          {
            type: types.SET_LOADING,
            payload: true,
          },
          {
            type: types.SET_HAS_ERROR,
            payload: false,
          },
        ],
        [],
      ));
  });

  describe('receiveProjectsSuccess', () => {
    it('commits the SET_PROJECTS mutation', () => {
      const projects = [];

      return testAction(
        actions.receiveProjectsSuccess,
        projects,
        state,
        [
          {
            type: types.SET_LOADING,
            payload: false,
          },
          {
            type: types.SET_PROJECTS,
            payload: projects,
          },
        ],
        [],
      );
    });
  });

  describe('receiveProjectsError', () => {
    it('commits the SET_HAS_ERROR mutation', () => {
      const projects = [];

      return testAction(
        actions.receiveProjectsError,
        projects,
        state,
        [
          {
            type: types.SET_HAS_ERROR,
            payload: true,
          },
        ],
        [],
      );
    });

    it('creates a flash error message', () => {
      actions.receiveProjectsError(mockDispatchContext);

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith({
        message: 'Unable to fetch vulnerable projects',
      });
    });
  });
});
