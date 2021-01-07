import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import State from 'ee/billings/seat_usage/store/state';
import * as types from 'ee/billings/seat_usage/store/mutation_types';
import * as actions from 'ee/billings/seat_usage/store/actions';
import { mockDataSeats } from 'ee_jest/billings/mock_data';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import Api from '~/api';

jest.mock('~/flash');

describe('seats actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = State();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    createFlash.mockClear();
  });

  describe('fetchBillableMembersList', () => {
    beforeEach(() => {
      gon.api_version = 'v4';
      state.namespaceId = 1;
    });

    it('passes correct arguments to Api call', () => {
      const payload = { page: 5, search: 'search string' };
      const spy = jest.spyOn(Api, 'fetchBillableGroupMembersList');

      testAction({
        action: actions.fetchBillableMembersList,
        payload,
        state,
        expectedMutations: expect.anything(),
        expectedActions: expect.anything(),
      });

      expect(spy).toBeCalledWith(state.namespaceId, expect.objectContaining(payload));

      spy.mockRestore();
    });

    describe('on success', () => {
      beforeEach(() => {
        mock
          .onGet('/api/v4/groups/1/billable_members')
          .replyOnce(200, mockDataSeats.data, mockDataSeats.headers);
      });

      it('should dispatch the request and success actions', () => {
        testAction({
          action: actions.fetchBillableMembersList,
          state,
          expectedActions: [
            { type: 'requestBillableMembersList' },
            {
              type: 'receiveBillableMembersListSuccess',
              payload: mockDataSeats,
            },
          ],
        });
      });
    });

    describe('on error', () => {
      beforeEach(() => {
        mock.onGet('/api/v4/groups/1/billable_members').replyOnce(404, {});
      });

      it('should dispatch the request and error actions', () => {
        testAction({
          action: actions.fetchBillableMembersList,
          state,
          expectedActions: [
            { type: 'requestBillableMembersList' },
            { type: 'receiveBillableMembersListError' },
          ],
        });
      });
    });
  });

  describe('requestBillableMembersList', () => {
    it('should commit the request mutation', () => {
      testAction({
        action: actions.requestBillableMembersList,
        state,
        expectedMutations: [{ type: types.REQUEST_BILLABLE_MEMBERS }],
      });
    });
  });

  describe('receiveBillableMembersListSuccess', () => {
    it('should commit the success mutation', () => {
      testAction({
        action: actions.receiveBillableMembersListSuccess,
        payload: mockDataSeats,
        state,
        expectedMutations: [
          { type: types.RECEIVE_BILLABLE_MEMBERS_SUCCESS, payload: mockDataSeats },
        ],
      });
    });
  });

  describe('receiveBillableMembersListError', () => {
    it('should commit the error mutation', async () => {
      await testAction({
        action: actions.receiveBillableMembersListError,
        state,
        expectedMutations: [{ type: types.RECEIVE_BILLABLE_MEMBERS_ERROR }],
      });

      expect(createFlash).toHaveBeenCalled();
    });
  });

  describe('resetMembers', () => {
    it('should commit mutation', () => {
      testAction({
        action: actions.resetMembers,
        state,
        expectedMutations: [{ type: types.RESET_MEMBERS }],
      });
    });
  });
});
