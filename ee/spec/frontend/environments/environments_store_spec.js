import Store from 'ee/environments/stores/environments_store';
import { serverDataList, deployBoardMockData } from './mock_data';

describe('Store', () => {
  let store;

  beforeEach(() => {
    store = new Store();
  });

  it('should store a non folder environment with deploy board if rollout_status key is provided', () => {
    const environment = {
      name: 'foo',
      size: 1,
      latest: {
        id: 1,
        rollout_status: deployBoardMockData,
      },
    };

    store.storeEnvironments([environment]);

    expect(store.state.environments[0].hasDeployBoard).toEqual(true);
    expect(store.state.environments[0].isDeployBoardVisible).toEqual(true);
    expect(store.state.environments[0].deployBoardData).toEqual(deployBoardMockData);
  });

  describe('deploy boards', () => {
    beforeEach(() => {
      const environment = {
        name: 'foo',
        size: 1,
        latest: {
          id: 1,
        },
        rollout_status: deployBoardMockData,
      };

      store.storeEnvironments([environment]);
    });

    it('should toggle deploy board property for given environment id', () => {
      store.toggleDeployBoard(1);

      expect(store.state.environments[0].isDeployBoardVisible).toEqual(false);
    });

    it('should keep deploy board data when updating environments', () => {
      expect(store.state.environments[0].deployBoardData).toEqual(deployBoardMockData);

      const environment = {
        name: 'foo',
        size: 1,
        latest: {
          id: 1,
        },
        rollout_status: deployBoardMockData,
      };
      store.storeEnvironments([environment]);

      expect(store.state.environments[0].deployBoardData).toEqual(deployBoardMockData);
    });

    it('should set hasLegacyAppLabel property', () => {
      expect(store.state.environments[0].deployBoardData).toEqual(deployBoardMockData);

      const environment = {
        name: 'foo',
        size: 1,
        latest: {
          id: 1,
        },
        rollout_status: {
          ...deployBoardMockData,
          status: 'not_found',
          has_legacy_app_label: true,
        },
      };
      store.storeEnvironments([environment]);

      expect(store.state.environments[0].hasLegacyAppLabel).toBe(true);
    });
  });

  describe('canaryCallout', () => {
    it('should add banner underneath the second environment', () => {
      store.storeEnvironments(serverDataList);

      expect(store.state.environments[1].showCanaryCallout).toEqual(true);
    });

    it('should add banner underneath first environment when only one environment', () => {
      store.storeEnvironments(serverDataList.slice(0, 1));

      expect(store.state.environments[0].showCanaryCallout).toEqual(true);
    });
  });
});
