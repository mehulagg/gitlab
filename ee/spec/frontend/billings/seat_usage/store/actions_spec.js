import MockAdapter from 'axios-mock-adapter';
import Api from 'ee/api';
import * as actions from 'ee/billings/seat_usage/store/actions';
import * as types from 'ee/billings/seat_usage/store/mutation_types';
import State from 'ee/billings/seat_usage/store/state';
import { mockDataSeats } from 'ee_jest/billings/mock_data';
import testAction from 'helpers/vuex_action_helper';
import * as GroupsApi from '~/api/groups_api';
import createFlash, { FLASH_TYPES } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatusCodes from '~/lib/utils/http_status';

jest.mock('~/flash');

describe('seats actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = State();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.reset();
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
    });

    describe('on success', () => {
      beforeEach(() => {
        mock
          .onGet('/api/v4/groups/1/billable_members')
          .replyOnce(httpStatusCodes.OK, mockDataSeats.data, mockDataSeats.headers);
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
        mock.onGet('/api/v4/groups/1/billable_members').replyOnce(httpStatusCodes.NOT_FOUND, {});
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

  describe('setMemberToRemove', () => {
    it('should commit the set member mutation', async () => {
      await testAction({
        action: actions.setMemberToRemove,
        state,
        expectedMutations: [{ type: types.SET_MEMBER_TO_REMOVE }],
      });
    });
  });

  describe('removeMember', () => {
    let groupsApiSpy;

    beforeEach(() => {
      groupsApiSpy = jest.spyOn(GroupsApi, 'removeMemberFromGroup');

      state = {
        namespaceId: 1,
        memberToRemove: {
          id: 2,
        },
      };
    });

    describe('on success', () => {
      beforeEach(() => {
        mock.onDelete('/api/v4/groups/1/members/2').reply(httpStatusCodes.OK);
      });

      it('dispatches the removeMemberSuccess action', async () => {
        await testAction({
          action: actions.removeMember,
          state,
          expectedActions: [{ type: 'removeMemberSuccess' }],
        });

        expect(groupsApiSpy).toHaveBeenCalled();
      });
    });

    describe('on error', () => {
      beforeEach(() => {
        mock.onDelete('/api/v4/groups/1/members/2').reply(httpStatusCodes.UNPROCESSABLE_ENTITY);
      });

      it('dispatches the removeMemberError action', async () => {
        await testAction({
          action: actions.removeMember,
          state,
          expectedActions: [{ type: 'removeMemberError' }],
        });

        expect(groupsApiSpy).toHaveBeenCalled();
      });
    });
  });

  describe('removeMemberSuccess', () => {
    it('dispatches fetchBillableMembersList', async () => {
      await testAction({
        action: actions.removeMemberSuccess,
        state,
        expectedActions: [{ type: 'fetchBillableMembersList' }],
        expectedMutations: [{ type: types.REMOVE_MEMBER_SUCCESS }],
      });

      expect(createFlash).toHaveBeenCalledWith({
        message: 'User was successfully removed',
        type: FLASH_TYPES.SUCCESS,
      });
    });
  });

  describe('removeMemberError', () => {
    it('commits remove member error', async () => {
      await testAction({
        action: actions.removeMemberError,
        state,
        expectedMutations: [{ type: types.REMOVE_MEMBER_ERROR }],
      });

      expect(createFlash).toHaveBeenCalledWith({
        message: 'An error occurred while removing a billable member',
      });
    });
  });
});
