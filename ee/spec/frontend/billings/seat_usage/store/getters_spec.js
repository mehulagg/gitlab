import State from 'ee/billings/seat_usage/store/state';
import * as getters from 'ee/billings/seat_usage/store/getters';
import { mockDataSeats, mockTableItems } from 'ee_jest/billings/mock_data';

describe('Seat usage table getters', () => {
  let state;

  beforeEach(() => {
    state = State();
  });

  describe('Table items', () => {
    it('should return expected value if data is provided', () => {
      state.members = [...mockDataSeats.data];

      expect(getters.tableItems(state)).toEqual(mockTableItems);
    });

    it('should return an empty array if data is not provided', () => {
      state.members = [];

      expect(getters.tableItems(state)).toEqual([]);
    });
  });
});
