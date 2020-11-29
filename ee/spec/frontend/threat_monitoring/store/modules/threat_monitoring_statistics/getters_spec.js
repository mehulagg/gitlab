import * as getters from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/getters';
import createState from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/state';

describe('threatMonitoringStatistics module getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('hasHistory', () => {
    it.each(['nominal', 'anomalous'])('returns true if there is any %s history data', type => {
      state.statistics.history[type] = ['foo'];
      expect(getters.hasHistory(state)).toBe(true);
    });

    it('returns false if there is no history', () => {
      state.statistics.history.nominal = [];
      state.statistics.history.anomalous = [];
      expect(getters.hasHistory(state)).toBe(false);
    });
  });
});
