import {
  getLabelsEndpoint,
  getMilestonesEndpoint,
  getDefaultStartDate,
  initDateArray,
  transformScatterData,
  getScatterPlotData,
  getMedianLineData,
} from 'ee/analytics/productivity_analytics/utils';

describe('Productivity Analytics utils', () => {
  const namespacePath = 'gitlab-org';
  const projectWithNamespace = 'gitlab-org/gitlab-test';

  describe('getLabelsEndpoint', () => {
    it('returns the group labels path when no project is given', () => {
      expect(getLabelsEndpoint(namespacePath)).toBe('/groups/gitlab-org/-/labels');
    });

    it('returns the project labels path when a project is given', () => {
      expect(getLabelsEndpoint(namespacePath, projectWithNamespace)).toBe(
        '/gitlab-org/gitlab-test/-/labels',
      );
    });
  });

  describe('getMilestonesEndpoint', () => {
    it('returns the group milestone path when no project is given', () => {
      expect(getMilestonesEndpoint(namespacePath)).toBe('/groups/gitlab-org/-/milestones');
    });

    it('returns the project milestone path when a project is given', () => {
      expect(getMilestonesEndpoint(namespacePath, projectWithNamespace)).toBe(
        '/gitlab-org/gitlab-test/-/milestones',
      );
    });
  });

  describe('getDefaultStartDate', () => {
    const realDateNow = Date.now;
    const defaultDaysInPast = 10;

    beforeAll(() => {
      const today = jest.fn(() => new Date('2019-10-01'));
      global.Date.now = today;
    });

    afterAll(() => {
      global.Date.now = realDateNow;
    });

    it('returns the minDate when the computed date (today minus defaultDaysInPast) is before the minDate', () => {
      const minDate = new Date('2019-09-30');

      expect(getDefaultStartDate(minDate, defaultDaysInPast)).toEqual(minDate);
    });

    it('returns the computed date (today minus defaultDaysInPast) when this is after the minDate', () => {
      const minDate = new Date('2019-09-01');

      expect(getDefaultStartDate(minDate, defaultDaysInPast)).toEqual(new Date('2019-09-21'));
    });
  });

  describe('initDateArray', () => {
    it('creates a two-dimensional array with 3 empty arrays for startDate=2019-09-01 and endDate=2019-09-03', () => {
      const startDate = new Date('2019-09-01');
      const endDate = new Date('2019-09-03');

      expect(initDateArray(startDate, endDate)).toEqual([[], [], []]);
    });
  });

  describe('transformScatterData', () => {
    it('transforms the raw scatter data into a two-dimensional array and groups by date', () => {
      const startDate = new Date('2019-10-29');
      const endDate = new Date('2019-11-01');
      const data = {
        1: { merged_at: '2019-10-29T11:10:00.000Z', metric: 10 },
        2: { merged_at: '2019-10-29T12:11:00.000Z', metric: 20 },
        3: { merged_at: '2019-10-30T13:13:00.000Z', metric: 30 },
        4: { merged_at: '2019-10-31T01:23:15.231Z', metric: 40 },
      };
      const result = transformScatterData(data, startDate, endDate);
      const expected = [
        [
          { merged_at: '2019-10-29T11:10:00.000Z', metric: 10 },
          { merged_at: '2019-10-29T12:11:00.000Z', metric: 20 },
        ],
        [{ merged_at: '2019-10-30T13:13:00.000Z', metric: 30 }],
        [{ merged_at: '2019-10-31T01:23:15.231Z', metric: 40 }],
        [],
      ];
      expect(result).toEqual(expected);
    });
  });

  describe('getScatterPlotData', () => {
    it('returns a subset of data for the given start and end date and flattens the data', () => {
      const startDate = new Date('2019-08-02');
      const endDate = new Date('2019-08-04');
      const data = [
        [{ merged_at: '2019-08-01T11:00:00.000Z', metric: 10 }],
        [{ merged_at: '2019-08-02T13:00:00.000Z', metric: 30 }],
        [{ merged_at: '2019-08-03T14:00:00.000Z', metric: 40 }],
        [
          { merged_at: '2019-08-04T15:00:00.000Z', metric: 50 },
          { merged_at: '2019-08-04T16:00:00.000Z', metric: 60 },
        ],
      ];
      const result = getScatterPlotData(data, startDate, endDate);
      const expected = [
        ['2019-08-02', 30, '2019-08-02T13:00:00.000Z'],
        ['2019-08-03', 40, '2019-08-03T14:00:00.000Z'],
        ['2019-08-04', 50, '2019-08-04T15:00:00.000Z'],
        ['2019-08-04', 60, '2019-08-04T16:00:00.000Z'],
      ];
      expect(result).toEqual(expected);
    });
  });

  describe('getMedianLineData', () => {
    const daysOffset = 2;

    it(`computes the median for every date in the data array based on the past ${daysOffset} days`, () => {
      const startDate = new Date('2019-08-04');
      const endDate = new Date('2019-08-06');
      const data = [
        [{ merged_at: '2019-08-01T11:00:00.000Z', metric: 10 }],
        [{ merged_at: '2019-08-02T13:00:00.000Z', metric: 30 }],
        [{ merged_at: '2019-08-03T14:00:00.000Z', metric: 40 }],
        [
          { merged_at: '2019-08-04T15:00:00.000Z', metric: 50 },
          { merged_at: '2019-08-04T16:00:00.000Z', metric: 60 },
        ],
        [{ merged_at: '2019-08-05T17:00:00.000Z', metric: 70 }],
        [{ merged_at: '2019-08-06T18:00:00.000Z', metric: 80 }],
      ];
      const result = getMedianLineData(data, startDate, endDate, daysOffset);
      const expected = [['2019-08-04', 45], ['2019-08-05', 55], ['2019-08-06', 65]];
      expect(result).toEqual(expected);
    });
  });
});
