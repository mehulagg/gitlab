import { PRESET_TYPES } from 'ee/roadmap/constants';
import {
  getTimeframeForQuartersView,
  extendTimeframeForQuartersView,
  getTimeframeForMonthsView,
  extendTimeframeForMonthsView,
  getTimeframeForWeeksView,
  extendTimeframeForWeeksView,
  extendTimeframeForAvailableWidth,
  getEpicsTimeframeRange,
  sortEpics,
} from 'ee/roadmap/utils/roadmap_utils';

import {
  mockTimeframeInitialDate,
  mockTimeframeQuartersPrepend,
  mockTimeframeQuartersAppend,
  mockTimeframeMonthsPrepend,
  mockTimeframeMonthsAppend,
  mockTimeframeWeeksPrepend,
  mockTimeframeWeeksAppend,
  mockUnsortedEpics,
} from '../mock_data';

const mockTimeframeQuarters = getTimeframeForQuartersView(mockTimeframeInitialDate);
const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);
const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

describe('getTimeframeForQuartersView', () => {
  let timeframe;

  beforeEach(() => {
    timeframe = getTimeframeForQuartersView(new Date(2018, 0, 1));
  });

  it('returns timeframe with total of 7 quarters', () => {
    expect(timeframe).toHaveLength(7);
  });

  it('each timeframe item has `quarterSequence`, `year` and `range` present', () => {
    const timeframeItem = timeframe[0];

    expect(timeframeItem.quarterSequence).toEqual(expect.any(Number));
    expect(timeframeItem.year).toEqual(expect.any(Number));
    expect(Array.isArray(timeframeItem.range)).toBe(true);
  });

  it('first timeframe item refers to 2 quarters prior to current quarter', () => {
    const timeframeItem = timeframe[0];
    const expectedQuarter = {
      0: { month: 6, date: 1 }, // 1 Jul 2017
      1: { month: 7, date: 1 }, // 1 Aug 2017
      2: { month: 8, date: 30 }, // 30 Sep 2017
    };

    expect(timeframeItem.quarterSequence).toEqual(3);
    expect(timeframeItem.year).toEqual(2017);
    timeframeItem.range.forEach((month, index) => {
      expect(month.getFullYear()).toBe(2017);
      expect(expectedQuarter[index].month).toBe(month.getMonth());
      expect(expectedQuarter[index].date).toBe(month.getDate());
    });
  });

  it('last timeframe item refers to 5th quarter from current quarter', () => {
    const timeframeItem = timeframe[timeframe.length - 1];
    const expectedQuarter = {
      0: { month: 0, date: 1 }, // 1 Jan 2019
      1: { month: 1, date: 1 }, // 1 Feb 2019
      2: { month: 2, date: 31 }, // 31 Mar 2019
    };

    expect(timeframeItem.quarterSequence).toEqual(1);
    expect(timeframeItem.year).toEqual(2019);
    timeframeItem.range.forEach((month, index) => {
      expect(month.getFullYear()).toBe(2019);
      expect(expectedQuarter[index].month).toBe(month.getMonth());
      expect(expectedQuarter[index].date).toBe(month.getDate());
    });
  });
});

describe('extendTimeframeForQuartersView', () => {
  it('returns extended timeframe into the past from current timeframe startDate', () => {
    const initialDate = mockTimeframeQuarters[0].range[0];

    const extendedTimeframe = extendTimeframeForQuartersView(initialDate, -9);

    expect(extendedTimeframe).toHaveLength(mockTimeframeQuartersPrepend.length);
    extendedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.year).toBe(mockTimeframeQuartersPrepend[index].year);
      expect(timeframeItem.quarterSequence).toBe(
        mockTimeframeQuartersPrepend[index].quarterSequence,
      );

      timeframeItem.range.forEach((rangeItem, j) => {
        expect(rangeItem.getTime()).toBe(mockTimeframeQuartersPrepend[index].range[j].getTime());
      });
    });
  });

  it('returns extended timeframe into the future from current timeframe endDate', () => {
    const initialDate = mockTimeframeQuarters[mockTimeframeQuarters.length - 1].range[2];

    const extendedTimeframe = extendTimeframeForQuartersView(initialDate, 9);

    expect(extendedTimeframe).toHaveLength(mockTimeframeQuartersAppend.length);
    extendedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.year).toBe(mockTimeframeQuartersAppend[index].year);
      expect(timeframeItem.quarterSequence).toBe(
        mockTimeframeQuartersAppend[index].quarterSequence,
      );

      timeframeItem.range.forEach((rangeItem, j) => {
        expect(rangeItem.getTime()).toBe(mockTimeframeQuartersAppend[index].range[j].getTime());
      });
    });
  });
});

describe('getTimeframeForMonthsView', () => {
  let timeframe;

  beforeEach(() => {
    timeframe = getTimeframeForMonthsView(new Date(2018, 0, 1));
  });

  it('returns timeframe with total of 8 months', () => {
    expect(timeframe).toHaveLength(8);
  });

  it('first timeframe item refers to 2 months prior to current month', () => {
    const timeframeItem = timeframe[0];
    const expectedMonth = {
      year: 2017,
      month: 10,
      date: 1,
    };

    expect(timeframeItem.getFullYear()).toBe(expectedMonth.year);
    expect(timeframeItem.getMonth()).toBe(expectedMonth.month);
    expect(timeframeItem.getDate()).toBe(expectedMonth.date);
  });

  it('last timeframe item refers to 6th month from current month', () => {
    const timeframeItem = timeframe[timeframe.length - 1];
    const expectedMonth = {
      year: 2018,
      month: 5,
      date: 30,
    };

    expect(timeframeItem.getFullYear()).toBe(expectedMonth.year);
    expect(timeframeItem.getMonth()).toBe(expectedMonth.month);
    expect(timeframeItem.getDate()).toBe(expectedMonth.date);
  });
});

describe('extendTimeframeForMonthsView', () => {
  it('returns extended timeframe into the past from current timeframe startDate', () => {
    const initialDate = mockTimeframeMonths[0];
    const extendedTimeframe = extendTimeframeForMonthsView(initialDate, -8);

    expect(extendedTimeframe).toHaveLength(mockTimeframeMonthsPrepend.length);
    extendedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.getTime()).toBe(mockTimeframeMonthsPrepend[index].getTime());
    });
  });

  it('returns extended timeframe into the future from current timeframe endDate', () => {
    const initialDate = mockTimeframeMonths[mockTimeframeMonths.length - 1];
    const extendedTimeframe = extendTimeframeForMonthsView(initialDate, 8);

    expect(extendedTimeframe).toHaveLength(mockTimeframeMonthsAppend.length);
    extendedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.getTime()).toBe(mockTimeframeMonthsAppend[index].getTime());
    });
  });
});

describe('getTimeframeForWeeksView', () => {
  let timeframe;

  beforeEach(() => {
    timeframe = getTimeframeForWeeksView(mockTimeframeInitialDate);
  });

  it('returns timeframe with total of 7 weeks', () => {
    expect(timeframe).toHaveLength(7);
  });

  it('first timeframe item refers to 2 weeks prior to current week', () => {
    const timeframeItem = timeframe[0];
    const expectedMonth = {
      year: 2017,
      month: 11,
      date: 17,
    };

    expect(timeframeItem.getFullYear()).toBe(expectedMonth.year);
    expect(timeframeItem.getMonth()).toBe(expectedMonth.month);
    expect(timeframeItem.getDate()).toBe(expectedMonth.date);
  });

  it('last timeframe item refers to 5th week from current month', () => {
    const timeframeItem = timeframe[timeframe.length - 1];
    const expectedMonth = {
      year: 2018,
      month: 0,
      date: 28,
    };

    expect(timeframeItem.getFullYear()).toBe(expectedMonth.year);
    expect(timeframeItem.getMonth()).toBe(expectedMonth.month);
    expect(timeframeItem.getDate()).toBe(expectedMonth.date);
  });

  it('returns timeframe starting on a specific date when provided with additional `length` param', () => {
    const initialDate = new Date(2018, 0, 7);

    timeframe = getTimeframeForWeeksView(initialDate, 5);
    const expectedTimeframe = [
      initialDate,
      new Date(2018, 0, 14),
      new Date(2018, 0, 21),
      new Date(2018, 0, 28),
      new Date(2018, 1, 4),
    ];

    expect(timeframe).toHaveLength(5);
    expectedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.getTime()).toBe(expectedTimeframe[index].getTime());
    });
  });
});

describe('extendTimeframeForWeeksView', () => {
  it('returns extended timeframe into the past from current timeframe startDate', () => {
    const extendedTimeframe = extendTimeframeForWeeksView(mockTimeframeWeeks[0], -6); // initialDate: 17 Dec 2017

    expect(extendedTimeframe).toHaveLength(mockTimeframeWeeksPrepend.length);
    extendedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.getTime()).toBe(mockTimeframeWeeksPrepend[index].getTime());
    });
  });

  it('returns extended timeframe into the future from current timeframe endDate', () => {
    const extendedTimeframe = extendTimeframeForWeeksView(
      mockTimeframeWeeks[mockTimeframeWeeks.length - 1], // initialDate: 28 Jan 2018
      6,
    );

    expect(extendedTimeframe).toHaveLength(mockTimeframeWeeksAppend.length);
    extendedTimeframe.forEach((timeframeItem, index) => {
      expect(timeframeItem.getTime()).toBe(mockTimeframeWeeksAppend[index].getTime());
    });
  });
});

describe('extendTimeframeForAvailableWidth', () => {
  let timeframe;
  let timeframeStart;
  let timeframeEnd;

  beforeEach(() => {
    timeframe = mockTimeframeMonths.slice();
    [timeframeStart] = timeframe;
    timeframeEnd = timeframe[timeframe.length - 1];
  });

  it('should not extend `timeframe` when availableTimeframeWidth is small enough to force horizontal scrollbar to show up', () => {
    extendTimeframeForAvailableWidth({
      availableTimeframeWidth: 100,
      presetType: PRESET_TYPES.MONTHS,
      timeframe,
      timeframeStart,
      timeframeEnd,
    });

    expect(timeframe).toHaveLength(mockTimeframeMonths.length);
  });

  it('should extend `timeframe` when availableTimeframeWidth is large enough that it can fit more timeframe items to show up horizontal scrollbar', () => {
    extendTimeframeForAvailableWidth({
      availableTimeframeWidth: 2000,
      presetType: PRESET_TYPES.MONTHS,
      timeframe,
      timeframeStart,
      timeframeEnd,
    });

    expect(timeframe).toHaveLength(12);
    expect(timeframe[0].getTime()).toBe(1504224000000); // 1 Sep 2017
    expect(timeframe[timeframe.length - 1].getTime()).toBe(1535673600000); // 31 Aug 2018
  });
});

describe('getEpicsTimeframeRange', () => {
  it('returns object containing startDate and dueDate based on provided timeframe for Quarters', () => {
    const timeframeQuarters = getTimeframeForQuartersView(new Date(2018, 0, 1));
    const range = getEpicsTimeframeRange({
      presetType: PRESET_TYPES.QUARTERS,
      timeframe: timeframeQuarters,
    });

    expect(range).toEqual(
      expect.objectContaining({
        timeframe: {
          start: '2017-07-01',
          end: '2019-03-31',
        },
      }),
    );
  });

  it('returns object containing startDate and dueDate based on provided timeframe for Months', () => {
    const timeframeMonths = getTimeframeForMonthsView(new Date(2018, 0, 1));
    const range = getEpicsTimeframeRange({
      presetType: PRESET_TYPES.MONTHS,
      timeframe: timeframeMonths,
    });

    expect(range).toEqual(
      expect.objectContaining({
        timeframe: {
          start: '2017-11-01',
          end: '2018-06-30',
        },
      }),
    );
  });

  it('returns object containing startDate and dueDate based on provided timeframe for Weeks', () => {
    const timeframeWeeks = getTimeframeForWeeksView(new Date(2018, 0, 1));
    const range = getEpicsTimeframeRange({
      presetType: PRESET_TYPES.WEEKS,
      timeframe: timeframeWeeks,
    });

    expect(range).toEqual(
      expect.objectContaining({
        timeframe: {
          start: '2017-12-17',
          end: '2018-02-03',
        },
      }),
    );
  });
});

describe('sortEpics', () => {
  it('sorts epics list by startDate in ascending order when `sortedBy` param is `start_date_asc`', () => {
    const epics = mockUnsortedEpics.slice();
    const sortedOrder = [
      'Jan 01 2020 ~ Dec 01 2020; no fixed start date',
      'Nov 10 2013 ~ Jun 01 2014; actual start date is Feb 1 2013',
      'Mar 01 2013 ~ Dec 01 2013; no fixed due date',
      'Oct 01 2013 ~ Nov 01 2013; actual due date is Nov 1 2014',
      'Mar 17 2014 ~ Aug 15 2015',
      'Jun 08 2015 ~ Apr 01 2016',
      'Mar 12 2017 ~ Aug 20 2017',
      'Apr 12 2019 ~ Aug 30 2019',
    ];

    sortEpics(epics, 'start_date_asc');

    expect(epics).toHaveLength(mockUnsortedEpics.length);

    epics.forEach((epic, index) => {
      expect(epic.title).toEqual(sortedOrder[index]);
    });
  });

  it('sorts epics list by startDate in descending order when `sortedBy` param is `start_date_desc`', () => {
    const epics = mockUnsortedEpics.slice();
    const sortedOrder = [
      'Apr 12 2019 ~ Aug 30 2019',
      'Mar 12 2017 ~ Aug 20 2017',
      'Jun 08 2015 ~ Apr 01 2016',
      'Mar 17 2014 ~ Aug 15 2015',
      'Oct 01 2013 ~ Nov 01 2013; actual due date is Nov 1 2014',
      'Mar 01 2013 ~ Dec 01 2013; no fixed due date',
      'Nov 10 2013 ~ Jun 01 2014; actual start date is Feb 1 2013',
      'Jan 01 2020 ~ Dec 01 2020; no fixed start date',
    ];

    sortEpics(epics, 'start_date_desc');

    expect(epics).toHaveLength(mockUnsortedEpics.length);

    epics.forEach((epic, index) => {
      expect(epic.title).toEqual(sortedOrder[index]);
    });
  });

  it('sorts epics list by endDate in ascending order when `sortedBy` param is `end_date_asc`', () => {
    const epics = mockUnsortedEpics.slice();
    const sortedOrder = [
      'Nov 10 2013 ~ Jun 01 2014; actual start date is Feb 1 2013',
      'Oct 01 2013 ~ Nov 01 2013; actual due date is Nov 1 2014',
      'Mar 17 2014 ~ Aug 15 2015',
      'Jun 08 2015 ~ Apr 01 2016',
      'Mar 12 2017 ~ Aug 20 2017',
      'Apr 12 2019 ~ Aug 30 2019',
      'Jan 01 2020 ~ Dec 01 2020; no fixed start date',
      'Mar 01 2013 ~ Dec 01 2013; no fixed due date',
    ];

    sortEpics(epics, 'end_date_asc');

    expect(epics).toHaveLength(mockUnsortedEpics.length);

    epics.forEach((epic, index) => {
      expect(epic.title).toEqual(sortedOrder[index]);
    });
  });

  it('sorts epics list by endDate in descending order when `sortedBy` param is `end_date_desc`', () => {
    const epics = mockUnsortedEpics.slice();
    const sortedOrder = [
      'Mar 01 2013 ~ Dec 01 2013; no fixed due date',
      'Jan 01 2020 ~ Dec 01 2020; no fixed start date',
      'Apr 12 2019 ~ Aug 30 2019',
      'Mar 12 2017 ~ Aug 20 2017',
      'Jun 08 2015 ~ Apr 01 2016',
      'Mar 17 2014 ~ Aug 15 2015',
      'Oct 01 2013 ~ Nov 01 2013; actual due date is Nov 1 2014',
      'Nov 10 2013 ~ Jun 01 2014; actual start date is Feb 1 2013',
    ];

    sortEpics(epics, 'end_date_desc');

    expect(epics).toHaveLength(mockUnsortedEpics.length);

    epics.forEach((epic, index) => {
      expect(epic.title).toEqual(sortedOrder[index]);
    });
  });
});
