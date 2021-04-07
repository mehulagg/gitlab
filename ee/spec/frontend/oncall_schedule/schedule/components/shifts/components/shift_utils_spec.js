import {
  currentTimeframeEndsAt,
  shiftsToRender,
  shiftShouldRender,
  weekShiftShouldRender,
  daysUntilEndOfTimeFrame,
  weekDisplayShiftLeft,
  weekDisplayShiftWidth,
  getTotalTime,
  getTimeOffset,
  getDuration,
  getPixelOffset,
  getPixelWidth,
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

  describe('weekDisplayShiftLeft', () => {
    const mockTimeframeInitialDate = new Date(2018, 0, 1);
    const shiftStartsAt = new Date(2018, 0, 2);
    const shiftTimeUnitWidth = 50;

    it.each`
      shiftUnitIsHour | daysOverlap | shiftStartDateOutOfRange | presetType            | value
      ${true}         | ${1}        | ${true}                  | ${PRESET_TYPES.DAYS}  | ${350}
      ${true}         | ${4}        | ${true}                  | ${PRESET_TYPES.DAYS}  | ${500}
      ${false}        | ${5}        | ${false}                 | ${PRESET_TYPES.DAYS}  | ${550}
      ${true}         | ${1}        | ${false}                 | ${PRESET_TYPES.WEEKS} | ${50}
      ${true}         | ${2}        | ${false}                 | ${PRESET_TYPES.WEEKS} | ${100}
      ${false}        | ${6}        | ${false}                 | ${PRESET_TYPES.WEEKS} | ${300}
      ${false}        | ${7}        | ${false}                 | ${PRESET_TYPES.WEEKS} | ${350}
      ${false}        | ${10}       | ${true}                  | ${PRESET_TYPES.WEEKS} | ${0}
    `(
      `returns $value px as the rotation left position when shiftUnitIsHour is $shiftUnitIsHour, shiftStartDateOutOfRange is $shiftStartDateOutOfRange and shiftTimeUnitWidth is ${shiftTimeUnitWidth}`,
      ({ shiftUnitIsHour, daysOverlap, shiftStartDateOutOfRange, presetType, value }) => {
        expect(
          weekDisplayShiftLeft(
            shiftUnitIsHour,
            { overlapStartDate: mockTimeStamp(mockTimeframeInitialDate, daysOverlap) },
            shiftStartDateOutOfRange,
            shiftTimeUnitWidth,
            shiftStartsAt,
            mockTimeframeInitialDate,
            presetType,
          ),
        ).toBe(value);
      },
    );
  });

  describe('weekDisplayShiftWidth', () => {
    const shiftTimeUnitWidth = 50;
    const mockTimeframeInitialDate = new Date('2018-01-01T00:00:00');

    it.each`
      shiftUnitIsHour | shiftRangeOverlapObject                 | shiftStartDateOutOfRange | value
      ${true}         | ${{ daysOverlap: 1, hoursOverlap: 1 }}  | ${false}                 | ${1}
      ${true}         | ${{ daysOverlap: 1, hoursOverlap: 4 }}  | ${false}                 | ${6}
      ${true}         | ${{ daysOverlap: 1, hoursOverlap: 8 }}  | ${false}                 | ${14}
      ${true}         | ${{ daysOverlap: 1, hoursOverlap: 24 }} | ${false}                 | ${48}
      ${true}         | ${{ daysOverlap: 1, hoursOverlap: 24 }} | ${true}                  | ${48}
      ${false}        | ${{ daysOverlap: 1, hoursOverlap: 24 }} | ${false}                 | ${48}
      ${false}        | ${{ daysOverlap: 2, hoursOverlap: 48 }} | ${false}                 | ${98}
      ${false}        | ${{ daysOverlap: 3, hoursOverlap: 72 }} | ${false}                 | ${148}
      ${false}        | ${{ daysOverlap: 3, hoursOverlap: 72 }} | ${true}                  | ${148}
    `(
      `returns $value px as the rotation width when shiftUnitIsHour is $shiftUnitIsHour, shiftStartDateOutOfRange is $shiftStartDateOutOfRange and shiftTimeUnitWidth is ${shiftTimeUnitWidth}`,
      ({
        shiftUnitIsHour,
        shiftRangeOverlapObject: { daysOverlap, hoursOverlap },
        shiftStartDateOutOfRange,
        value,
      }) => {
        expect(
          weekDisplayShiftWidth(
            shiftUnitIsHour,
            {
              overlapEndDate: mockTimeStamp(mockTimeframeInitialDate, daysOverlap),
              daysOverlap,
              hoursOverlap,
            },
            shiftStartDateOutOfRange,
            shiftTimeUnitWidth,
          ),
        ).toBe(value);
      },
    );
  });

  it('returns with an offset of 1 day width less only when the shift start date is before the timeframe start and the shift does not end at midnight', () => {
    const mockOverlapEndDateNotAtMidnight = new Date('2018-01-01T03:02:01');

    expect(
      weekDisplayShiftWidth(
        false,
        { overlapEndDate: mockOverlapEndDateNotAtMidnight, daysOverlap: 3, hoursOverlap: 72 },
        true,
        50,
      ),
    ).toBe(98);
  });

  describe('shift utils', () => {
    // An 8 hour shift
    const shift = {
      startsAt: '2021-01-13T12:00:00.000Z',
      endsAt: '2021-01-13T20:00:00.000Z',
      participant: null,
    };

    const ONE_HOUR = 60 * 60 * 1000;
    const EIGHT_HOURS = 8 * ONE_HOUR;
    const TWELVE_HOURS = 12 * ONE_HOUR;
    const ONE_DAY = 2 * TWELVE_HOURS;
    const TWO_WEEKS = 14 * ONE_DAY;

    describe('getTotalTime', () => {
      it('returns the correct length for the days view', () => {
        expect(getTotalTime(PRESET_TYPES.DAYS)).toBe(ONE_DAY);
      });

      it('returns the correct length for the 2 week view', () => {
        expect(getTotalTime(PRESET_TYPES.WEEKS)).toBe(TWO_WEEKS);
      });
    });

    describe('getTimeOffset', () => {
      it('calculates the correct time offest', () => {
        const timelineStartDate = new Date('2021-01-13T00:00:00.000Z');
        const offset = getTimeOffset(timelineStartDate, shift);
        expect(offset).toBe(TWELVE_HOURS);
      });
    });

    describe('getDuration', () => {
      it('calculates the correct duration', () => {
        const duration = getDuration(shift);
        expect(duration).toBe(EIGHT_HOURS); // 8 hours
      });
    });

    describe('getPixelOffset', () => {
      it('calculates the correct pixel offest', () => {
        const timeframe = [
          new Date('2021-01-13T00:00:00.000Z'),
          new Date('2021-01-14T00:00:00.000Z'),
        ];
        const timelineWidth = 1000;
        const presetType = PRESET_TYPES.DAYS;
        const pixelOffset = getPixelOffset({ timeframe, shift, timelineWidth, presetType });
        expect(pixelOffset).toBe(500); // midday = half the total width
      });
    });

    describe('getPixelWidth', () => {
      it('calculates the correct pixel width', () => {
        const timelineWidth = 1200; // 50 pixels per hour
        const presetType = PRESET_TYPES.DAYS;
        const shiftDLSOffset = 60; // one hour
        const pixelWidth = getPixelWidth({ shift, timelineWidth, presetType, shiftDLSOffset });
        expect(pixelWidth).toBe(450); // 7 hrs
      });
    });
  });
});
