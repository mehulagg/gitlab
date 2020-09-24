import { getTimeWindowConfig, getTimeWindowParams } from 'ee/threat_monitoring/store/utils';
import { defaultTimeRange, timeRanges } from '~/vue_shared/constants';

describe('threatMonitoring module utils', () => {
  describe('getTimeWindowConfig', () => {
    it('gives the correct config for a valid time window', () => {
      Object.entries(timeRanges).forEach(([, timeWindow]) => {
        const timeWindowConfig = getTimeWindowConfig(timeWindow.name);
        expect(timeWindowConfig.interval).toBe(timeWindow.interval);
        expect(timeWindowConfig.durationInMilliseconds).toBe(timeWindow.duration.seconds * 1000);
      });
    });

    it('gives the default name for an invalid time window', () => {
      const timeWindowConfig = getTimeWindowConfig('foo');
      expect(timeWindowConfig.interval).toBe(defaultTimeRange.interval);
      expect(timeWindowConfig.durationInMilliseconds).toBe(
        defaultTimeRange.duration.seconds * 1000,
      );
    });
  });

  describe('getTimeWindowParams', () => {
    const mockTimestamp = new Date(2020, 0, 1, 10).getTime();

    it.each`
      timeWindowName     | expectedFrom                  | interval
      ${'thirtyMinutes'} | ${'2020-01-01T09:30:00.000Z'} | ${'minute'}
      ${'threeHours'}    | ${'2020-01-01T07:00:00.000Z'} | ${'hour'}
      ${'eightHours'}    | ${'2020-01-01T02:00:00.000Z'} | ${'hour'}
      ${'oneDay'}        | ${'2019-12-31T10:00:00.000Z'} | ${'hour'}
      ${'threeDays'}     | ${'2019-12-29T10:00:00.000Z'} | ${'hour'}
      ${'oneWeek'}       | ${'2019-12-25T10:00:00.000Z'} | ${'day'}
      ${'oneMonth'}      | ${'2019-12-02T10:00:00.000Z'} | ${'day'}
      ${'foo'}           | ${'2020-01-01T02:00:00.000Z'} | ${'hour'}
    `(
      'returns the expected params given "$timeWindowName"',
      ({ timeWindowName, expectedFrom, interval }) => {
        expect(getTimeWindowParams(timeWindowName, mockTimestamp)).toEqual({
          from: expectedFrom,
          to: '2020-01-01T10:00:00.000Z',
          interval,
        });
      },
    );
  });
});
