import SidebarStore from 'ee/sidebar/stores/sidebar_store';
import CESidebarStore from '~/sidebar/stores/sidebar_store';

describe('EE Sidebar store', () => {
  let store;
  beforeEach(() => {
    store = new SidebarStore({
      status: '',
      weight: null,
      weightOptions: ['None', 0, 1, 3],
      weightNoneValue: 'None',
    });
  });

  afterEach(() => {
    // Since CESidebarStore stores the actual singleton instance
    // we need to clear that specific reference
    CESidebarStore.singleton = null;
  });

  describe('setStatusData', () => {
    it('sets status data', () => {
      const graphQlData = {
        project: {
          issue: {
            healthStatus: 'onTrack',
          },
        },
      };

      store.setStatusData(graphQlData);

      expect(store.isFetching.status).toBe(false);
      expect(store.status).toBe(graphQlData.project.issue.healthStatus);
    });
  });

  describe('setStatus', () => {
    it('sets status', () => {
      expect(store.status).toBe('');
      const status = 'onTrack';
      store.setStatus(status);

      expect(store.status).toBe(status);
    });
  });

  describe('setWeightData', () => {
    it('sets weight data', () => {
      const weight = 3;
      store.setWeightData({
        weight,
      });

      expect(store.isFetching.weight).toBe(false);
      expect(store.weight).toBe(weight);
    });

    it('supports 0 weight', () => {
      store.setWeightData({
        weight: 0,
      });

      expect(store.weight).toBe(0);
    });
  });

  it('set weight', () => {
    expect(store.weight).toBe(null);
    const weight = 1;
    store.setWeight(weight);

    expect(store.weight).toBe(weight);
  });
});
