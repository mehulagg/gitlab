import {
  currentTimeframeEndsAt,
  shiftsToRender,
  shiftShouldRender,
  weekShiftShouldRender,
  daysUntilEndOfTimeFrame,
} from 'ee/oncall_schedules/components/schedule/components/shifts/components/shift_utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';

const mockTimeStamp = (timeframe, days) => new Date(2018, 0, 1).setDate(timeframe.getDate() + days);

describe('~ee/oncall_schedules/components/schedule/components/shifts/components/shift_utils.js', () => {
  describe('currentTimeframeEndsAt', () => {
    const mockTimeframeInitialDate = new Date(2018, 0, 1);
    const mockTimeFrameWeekAheadDate = new Date(2018, 0, 8);

    it('returns a new date 1 week ahead when supplied a week preset', () => {
      expect(currentTimeframeEndsAt(mockTimeframeInitialDate, PRESET_TYPES.WEEKS)).toStrictEqual(
        mockTimeFrameWeekAheadDate,
      );
    });

    it('returns a new date 1 day ahead when supplied a day preset', () => {
      expect(currentTimeframeEndsAt(mockTimeframeInitialDate, PRESET_TYPES.DAYS)).toStrictEqual(
        new Date(2018, 0, 2),
      );
    });

    it('returns a new date 1 week ahead when provided no preset', () => {
      expect(currentTimeframeEndsAt(mockTimeframeInitialDate)).toStrictEqual(
        mockTimeFrameWeekAheadDate,
      );
    });

    it('returns an error when a invalid Date instance is supplied', () => {
      const error = 'Invalid date';
      expect(() => currentTimeframeEndsAt('anInvalidDate')).toThrow(error);
    });
  });

  describe('shiftsToRender', () => {
    const shifts = [
      { startsAt: '2018-01-01', endsAt: '2018-01-03' },
      { startsAt: '2018-01-16', endsAt: '2018-01-17' },
    ];
    const mockTimeframeItem = new Date(2018, 0, 1);
    const presetType = PRESET_TYPES.WEEKS;

    it('returns an an empty array when no shifts are provided', () => {
      expect(shiftsToRender([], mockTimeframeItem, presetType)).toHaveLength(0);
    });

    it('returns an empty array when no overlapping shifts are present', () => {
      expect(shiftsToRender([shifts[1]], mockTimeframeItem, presetType)).toHaveLength(0);
    });

    it('returns an array with overlapping shifts that are present', () => {
      expect(shiftsToRender(shifts, mockTimeframeItem, presetType)).toHaveLength(1);
    });
  });

  describe('shiftShouldRender', () => {
    const validMockShiftRangeOverlap = { hoursOverlap: 48 };
    const validEmptyMockShiftRangeOverlap = { hoursOverlap: 0 };
    const invalidMockShiftRangeOverlap = { hoursOverlap: 0 };

    it('returns true if there is an hour overlap present', () => {
      expect(shiftShouldRender(validMockShiftRangeOverlap)).toBe(true);
    });

    it('returns false if there is no hour overlap present', () => {
      expect(shiftShouldRender(validEmptyMockShiftRangeOverlap)).toBe(false);
    });

    it('returns false if an invalid shift object is supplied', () => {
      expect(shiftShouldRender(invalidMockShiftRangeOverlap)).toBe(false);
    });
  });

  describe('weekShiftShouldRender', () => {
    const timeframeItem = new Date(2018, 0, 1);
    const shiftStartsAt = new Date(2018, 0, 2);
    const timeframeIndex = 0;
    const mockTimeframeIndexGreaterThanZero = 1;
    // Shift overlaps by 6 days
    const shiftRangeOverlap = {
      overlapStartDate: mockTimeStamp(timeframeItem, 1),
      hoursOverlap: 144,
    };

    it('returns true when the current shift has an valid hour overlap', () => {
      expect(
        weekShiftShouldRender(shiftRangeOverlap, timeframeIndex, shiftStartsAt, timeframeItem),
      ).toBe(true);
    });

    it('returns false when the current shift does not have an hour overlap', () => {
      // Shift has no overlap with timeframe
      const shiftRangeOverlapOutOfRange = {
        overlapStartDate: mockTimeStamp(timeframeItem, 8),
        hoursOverlap: 0,
      };
      expect(
        weekShiftShouldRender(
          shiftRangeOverlapOutOfRange,
          timeframeIndex,
          shiftStartsAt,
          timeframeItem,
        ),
      ).toBe(false);
    });

    it('returns true when the current timeframe index is greater than 0 and shift start/end time is inside current timeframe', () => {
      const shiftStartsAtSameDayAsTimeFrame = new Date(2018, 0, 1);
      expect(
        weekShiftShouldRender(
          shiftRangeOverlap,
          mockTimeframeIndexGreaterThanZero,
          shiftStartsAtSameDayAsTimeFrame,
          timeframeItem,
        ),
      ).toBe(true);
    });

    it('returns true when the current timeframe index is greater than 0 and shift start time is the start date of the current timeframe', () => {
      expect(
        weekShiftShouldRender(
          shiftRangeOverlap,
          mockTimeframeIndexGreaterThanZero,
          shiftStartsAt,
          timeframeItem,
        ),
      ).toBe(true);
    });
  });

  describe('daysUntilEndOfTimeFrame', () => {
    const mockTimeframeInitialDate = new Date(2018, 0, 1);
    const endOfTimeFrame = new Date(2018, 0, 7);

    it.each`
      timeframe                   | presetType            | shiftRangeOverlap                                                   | value
      ${mockTimeframeInitialDate} | ${PRESET_TYPES.WEEKS} | ${{ overlapStartDate: mockTimeStamp(mockTimeframeInitialDate, 0) }} | ${7}
      ${mockTimeframeInitialDate} | ${PRESET_TYPES.WEEKS} | ${{ overlapStartDate: mockTimeStamp(mockTimeframeInitialDate, 2) }} | ${5}
      ${mockTimeframeInitialDate} | ${PRESET_TYPES.WEEKS} | ${{ overlapStartDate: mockTimeStamp(mockTimeframeInitialDate, 4) }} | ${3}
      ${mockTimeframeInitialDate} | ${PRESET_TYPES.WEEKS} | ${{ overlapStartDate: mockTimeStamp(mockTimeframeInitialDate, 5) }} | ${2}
      ${mockTimeframeInitialDate} | ${PRESET_TYPES.WEEKS} | ${{ overlapStartDate: mockTimeStamp(mockTimeframeInitialDate, 7) }} | ${0}
    `(
      `returns $value days until ${endOfTimeFrame} when shift overlap starts at $shiftRangeOverlap`,
      ({ timeframe, presetType, shiftRangeOverlap, value }) => {
        expect(daysUntilEndOfTimeFrame(shiftRangeOverlap, timeframe, presetType)).toBe(value);
      },
    );

    it('returns the positive day difference between the timeframe end date and the shift start date if the timeframe changes month', () => {
      const mockTimeframeEndOfMonth = new Date(2018, 0, 31);
      const mockTimeframeStartOfNewMonth = new Date(2018, 1, 3);

      expect(
        daysUntilEndOfTimeFrame(
          { overlapStartDate: mockTimeframeStartOfNewMonth },
          mockTimeframeEndOfMonth,
          PRESET_TYPES.WEEKS,
        ),
      ).toBe(4);
    });

    it('returns NaN for invalid argument entries', () => {
      const mockTimeframeEndOfMonth = new Date(2018, 0, 31);

      expect(daysUntilEndOfTimeFrame({}, mockTimeframeEndOfMonth, PRESET_TYPES.WEEKS)).toBe(NaN);
    });
  });
});
