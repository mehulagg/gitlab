import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/threat_monitoring/store/modules/network_policies/actions';
import * as types from 'ee/threat_monitoring/store/modules/network_policies/mutation_types';
import getInitialState from 'ee/threat_monitoring/store/modules/network_policies/state';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import { joinPaths } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';

import { mockPoliciesResponse } from '../../../mocks/mock_data';

jest.mock('~/flash');

const networkPoliciesEndpoint = 'networkPoliciesEndpoint';

describe('Network Policy actions', () => {
  let state;
  let mock;
  const environmentId = 3;
  const policy = { name: 'policy', manifest: 'foo', isEnabled: true };

  beforeEach(() => {
    state = getInitialState();
    state.policiesEndpoint = networkPoliciesEndpoint;
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    createFlash.mockClear();
    mock.restore();
  });

  describe('setEndpoints', () => {
    it('commits the SET_ENDPOINT mutation', () =>
      testAction(
        actions.setEndpoints,
        { networkPoliciesEndpoint },
        state,
        [
          {
            type: types.SET_ENDPOINT,
            payload: networkPoliciesEndpoint,
          },
        ],
        [],
      ));
  });

  describe('fetchPolicies', () => {
    describe('on success', () => {
      beforeEach(() => {
        mock
          .onGet(networkPoliciesEndpoint, {
            params: { environment_id: environmentId },
          })
          .replyOnce(httpStatus.OK, mockPoliciesResponse);
      });

      it('should dispatch the request and success actions', () =>
        testAction(
          actions.fetchPolicies,
          environmentId,
          state,
          [
            { type: types.REQUEST_POLICIES },
            {
              type: types.RECEIVE_POLICIES_SUCCESS,
              payload: mockPoliciesResponse,
            },
          ],
          [],
        ));

      describe('without environment id', () => {
        beforeEach(() => {
          mock.onGet(networkPoliciesEndpoint, null).replyOnce(httpStatus.OK, mockPoliciesResponse);
        });
        it('should dispatch the request and success actions', () =>
          testAction(
            actions.fetchPolicies,
            null,
            state,
            [
              { type: types.REQUEST_POLICIES },
              {
                type: types.RECEIVE_POLICIES_SUCCESS,
                payload: mockPoliciesResponse,
              },
            ],
            [],
          ));
      });
    });

    describe('on error', () => {
      describe('without payload', () => {
        const error = { error: 'foo' };

        beforeEach(() => {
          mock.onGet(networkPoliciesEndpoint).replyOnce(500, error);
        });

        it('should dispatch the request, error actions and updates payload', () =>
          testAction(
            actions.fetchPolicies,
            environmentId,
            state,
            [{ type: types.REQUEST_POLICIES }, { type: types.RECEIVE_POLICIES_ERROR, payload: [] }],
            [],
          ).then(() => {
            expect(createFlash).toHaveBeenCalled();
          }));
      });

      describe('with payload', () => {
        const payload = { error: 'foo', payload: [policy] };

        beforeEach(() => {
          mock.onGet(networkPoliciesEndpoint).replyOnce(500, payload);
        });

        it('should dispatch the request, error actions and updates payload', () =>
          testAction(
            actions.fetchPolicies,
            environmentId,
            state,
            [
              { type: types.REQUEST_POLICIES },
              { type: types.RECEIVE_POLICIES_ERROR, payload: [policy] },
            ],
            [],
          ).then(() => {
            expect(createFlash).toHaveBeenCalled();
          }));
      });
    });

    describe('with an empty endpoint', () => {
      beforeEach(() => {
        state.policiesEndpoint = '';
      });

      it('should dispatch RECEIVE_POLICES_ERROR', () =>
        testAction(
          actions.fetchPolicies,
          environmentId,
          state,
          [
            {
              type: types.RECEIVE_POLICIES_ERROR,
              payload: [],
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });
  });

  describe('createPolicy', () => {
    const createdPolicy = { name: 'policy', manifest: 'bar', isEnabled: true };

    describe('on success', () => {
      beforeEach(() => {
        mock
          .onPost(networkPoliciesEndpoint, {
            environment_id: environmentId,
            manifest: policy.manifest,
          })
          .replyOnce(httpStatus.OK, createdPolicy);
      });

      it('should dispatch the request and success actions', () =>
        testAction(
          actions.createPolicy,
          { environmentId, policy },
          state,
          [
            { type: types.REQUEST_CREATE_POLICY },
            {
              type: types.RECEIVE_CREATE_POLICY_SUCCESS,
              payload: createdPolicy,
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('on error', () => {
      const error = { error: 'foo' };

      beforeEach(() => {
        mock
          .onPost(networkPoliciesEndpoint, {
            environment_id: environmentId,
            manifest: policy.manifest,
          })
          .replyOnce(500, error);
      });

      it('should dispatch the request and error actions', () =>
        testAction(
          actions.createPolicy,
          { environmentId, policy },
          state,
          [
            { type: types.REQUEST_CREATE_POLICY },
            { type: types.RECEIVE_CREATE_POLICY_ERROR, payload: 'foo' },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('with an empty endpoint', () => {
      beforeEach(() => {
        state.policiesEndpoint = '';
      });

      it('should dispatch RECEIVE_CREATE_POLICY_ERROR', () =>
        testAction(
          actions.createPolicy,
          { environmentId, policy },
          state,
          [
            {
              type: types.RECEIVE_CREATE_POLICY_ERROR,
              payload: s__('NetworkPolicies|Something went wrong, failed to update policy'),
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('without environment id', () => {
      it('should dispatch RECEIVE_CREATE_POLICY_ERROR', () =>
        testAction(
          actions.createPolicy,
          {
            environmentId: undefined,
            policy,
          },
          state,
          [
            {
              type: types.RECEIVE_CREATE_POLICY_ERROR,
              payload: s__('NetworkPolicies|Something went wrong, failed to update policy'),
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });
  });

  describe('updatePolicy', () => {
    const updatedPolicy = { name: 'policy', manifest: 'bar', isEnabled: true };

    describe('on success', () => {
      beforeEach(() => {
        mock
          .onPut(joinPaths(networkPoliciesEndpoint, policy.name), {
            environment_id: environmentId,
            manifest: policy.manifest,
            enabled: policy.isEnabled,
          })
          .replyOnce(httpStatus.OK, updatedPolicy);
      });

      it('should dispatch the request and success actions', () =>
        testAction(
          actions.updatePolicy,
          { environmentId, policy },
          state,
          [
            { type: types.REQUEST_UPDATE_POLICY },
            {
              type: types.RECEIVE_UPDATE_POLICY_SUCCESS,
              payload: { policy, updatedPolicy },
            },
          ],
          [],
        ));
    });

    describe('on error', () => {
      const error = { error: 'foo' };

      beforeEach(() => {
        mock
          .onPut(joinPaths(networkPoliciesEndpoint, policy.name), {
            environment_id: environmentId,
            manifest: policy.manifest,
            enabled: policy.isEnabled,
          })
          .replyOnce(500, error);
      });

      it('should dispatch the request and error actions', () =>
        testAction(
          actions.updatePolicy,
          { environmentId, policy },
          state,
          [
            { type: types.REQUEST_UPDATE_POLICY },
            { type: types.RECEIVE_UPDATE_POLICY_ERROR, payload: 'foo' },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('with an empty endpoint', () => {
      beforeEach(() => {
        state.policiesEndpoint = '';
      });

      it('should dispatch RECEIVE_UPDATE_POLICY_ERROR', () =>
        testAction(
          actions.updatePolicy,
          { environmentId, policy },
          state,
          [
            {
              type: types.RECEIVE_UPDATE_POLICY_ERROR,
              payload: s__('NetworkPolicies|Something went wrong, failed to update policy'),
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('without environment id', () => {
      it('should dispatch RECEIVE_UPDATE_POLICY_ERROR', () =>
        testAction(
          actions.updatePolicy,
          {
            environmentId: undefined,
            policy,
          },
          state,
          [
            {
              type: types.RECEIVE_UPDATE_POLICY_ERROR,
              payload: s__('NetworkPolicies|Something went wrong, failed to update policy'),
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });
  });

  describe('deletePolicy', () => {
    describe('on success', () => {
      beforeEach(() => {
        mock
          .onDelete(joinPaths(networkPoliciesEndpoint, policy.name), {
            params: {
              environment_id: environmentId,
              manifest: policy.manifest,
            },
          })
          .replyOnce(httpStatus.OK);
      });

      it('should dispatch the request and success actions', () =>
        testAction(
          actions.deletePolicy,
          { environmentId, policy },
          state,
          [
            { type: types.REQUEST_DELETE_POLICY },
            {
              type: types.RECEIVE_DELETE_POLICY_SUCCESS,
              payload: { policy },
            },
          ],
          [],
        ));
    });

    describe('on error', () => {
      const error = { error: 'foo' };

      beforeEach(() => {
        mock
          .onDelete(joinPaths(networkPoliciesEndpoint, policy.name), {
            params: {
              environment_id: environmentId,
              manifest: policy.manifest,
            },
          })
          .replyOnce(500, error);
      });

      it('should dispatch the request and error actions', () =>
        testAction(
          actions.deletePolicy,
          { environmentId, policy },
          state,
          [
            { type: types.REQUEST_DELETE_POLICY },
            { type: types.RECEIVE_DELETE_POLICY_ERROR, payload: 'foo' },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('with an empty endpoint', () => {
      beforeEach(() => {
        state.policiesEndpoint = '';
      });

      it('should dispatch RECEIVE_DELETE_POLICY_ERROR', () =>
        testAction(
          actions.deletePolicy,
          { environmentId, policy },
          state,
          [
            {
              type: types.RECEIVE_DELETE_POLICY_ERROR,
              payload: s__('NetworkPolicies|Something went wrong, failed to update policy'),
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });

    describe('without environment id', () => {
      it('should dispatch RECEIVE_DELETE_POLICY_ERROR', () =>
        testAction(
          actions.deletePolicy,
          {
            environmentId: undefined,
            policy,
          },
          state,
          [
            {
              type: types.RECEIVE_DELETE_POLICY_ERROR,
              payload: s__('NetworkPolicies|Something went wrong, failed to update policy'),
            },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });
  });
});
