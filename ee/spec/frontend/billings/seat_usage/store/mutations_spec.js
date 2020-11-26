import createState from 'ee/billings/seat_usage/store/state';
import * as types from 'ee/billings/seat_usage/store/mutation_types';
import mutations from 'ee/billings/seat_usage/store/mutations';
import { mockDataSeats } from 'ee_jest/billings/mock_data';

describe('EE billings seats module mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe(types.REQUEST_BILLABLE_MEMBERS, () => {
    beforeEach(() => {
      mutations[types.REQUEST_BILLABLE_MEMBERS](state);
    });

    it('sets isLoading to true', () => {
      expect(state.isLoading).toBeTruthy();
    });

    it('sets hasError to false', () => {
      expect(state.hasError).toBeFalsy();
    });
  });

  describe(types.RECEIVE_BILLABLE_MEMBERS_SUCCESS, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_BILLABLE_MEMBERS_SUCCESS](state, mockDataSeats);
    });

    it('sets state as expected', () => {
      expect(state.total).toBe('3');
      expect(state.page).toBe('1');
      expect(state.perPage).toBe('1');
    });

    it('sets isLoading to false', () => {
      expect(state.isLoading).toBeFalsy();
    });
  });

  describe(types.RECEIVE_BILLABLE_MEMBERS_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_BILLABLE_MEMBERS_ERROR](state);
    });

    it('sets isLoading to false', () => {
      expect(state.isLoading).toBeFalsy();
    });

    it('sets hasError to true', () => {
      expect(state.hasError).toBeTruthy();
    });
  });
});
