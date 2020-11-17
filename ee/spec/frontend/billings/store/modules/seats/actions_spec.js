import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/billings/stores/modules/seats/actions';
import * as types from 'ee/billings/stores/modules/seats/mutation_types';
import state from 'ee/billings/stores/modules/seats/state';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { mockDataSeats } from '../../../mock_data';

jest.mock('~/flash');

describe('seats actions', () => {
  let mockedState;
  let mock;

  beforeEach(() => {
    mockedState = state();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    createFlash.mockClear();
  });

  describe('setNamespaceId', () => {
    it('should commit the correct mutuation', () => {
      const namespaceId = 1;

      testAction(
        actions.setNamespaceId,
        namespaceId,
        mockedState,
        [
          {
            type: types.SET_NAMESPACE_ID,
            payload: namespaceId,
          },
        ],
        [],
      );
    });
  });

  describe('fetchBillableMembersList', () => {
    beforeEach(() => {
      gon.api_version = 'v4';
      mockedState.namespaceId = 1;
    });

    describe('on success', () => {
      beforeEach(() => {
        mock
          .onGet('/api/v4/groups/1/billable_members')
          .replyOnce(200, mockDataSeats.data, mockDataSeats.headers);
      });

      it('should dispatch the request and success actions', () => {
        testAction(
          actions.fetchBillableMembersList,
          {},
          mockedState,
          [],
          [
            { type: 'requestBillableMembersList' },
            {
              type: 'receiveBillableMembersListSuccess',
              payload: mockDataSeats,
            },
          ],
        );
      });
    });

    describe('on error', () => {
      beforeEach(() => {
        mock.onGet('/api/v4/groups/1/billable_members').replyOnce(404, {});
      });

      it('should dispatch the request and error actions', () => {
        testAction(
          actions.fetchBillableMembersList,
          {},
          mockedState,
          [],
          [{ type: 'requestBillableMembersList' }, { type: 'receiveBillableMembersListError' }],
        );
      });
    });
  });

  describe('requestBillableMembersList', () => {
    it('should commit the request mutation', () => {
      testAction(
        actions.requestBillableMembersList,
        {},
        state,
        [{ type: types.REQUEST_BILLABLE_MEMBERS }],
        [],
      );
    });
  });

  describe('receiveBillableMembersListSuccess', () => {
    it('should commit the success mutation', () => {
      testAction(
        actions.receiveBillableMembersListSuccess,
        mockDataSeats,
        mockedState,
        [
          {
            type: types.RECEIVE_BILLABLE_MEMBERS_SUCCESS,
            payload: mockDataSeats,
          },
        ],
        [],
      );
    });
  });

  describe('receiveBillableMembersListError', () => {
    it('should commit the error mutation', done => {
      testAction(
        actions.receiveBillableMembersListError,
        {},
        mockedState,
        [{ type: types.RECEIVE_BILLABLE_MEMBERS_ERROR }],
        [],
        () => {
          expect(createFlash).toHaveBeenCalled();
          done();
        },
      );
    });
  });
});
