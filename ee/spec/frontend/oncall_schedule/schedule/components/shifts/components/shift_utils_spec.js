import { milliseconds } from 'ee/oncall_schedules/components/schedule/components/shifts/components/shift_utils';

describe('~ee/oncall_schedules/components/schedule/components/shifts/components/shift_utils.js', () => {
  describe('milliseconds', () => {
    const mockDSLOffset = { m: 300 };

    it('returns a millisecond representation of a passed object', () => {
      expect(milliseconds(mockDSLOffset)).toBe(18000000);
    });
  });
});
