import { mount, shallowMount } from '@vue/test-utils';
import EnvironmentAlert from 'ee/environments/components/environment_alert.vue';
import EnvironmentTable from '~/environments/components/environments_table.vue';
import eventHub from '~/environments/event_hub';
import { deployBoardMockData } from './mock_data';

describe('Environment table', () => {
  let wrapper;

  const factory = async (options = {}, m = mount) => {
    // This destroys any wrappers created before a nested call to factory reassigns it
    if (wrapper && wrapper.destroy) {
      wrapper.destroy();
    }
    wrapper = m(EnvironmentTable, {
      ...options,
    });
    await wrapper.vm.$nextTick();
    await jest.runOnlyPendingTimers();
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('Should render a table', async () => {
    const mockItem = {
      name: 'review',
      folderName: 'review',
      size: 3,
      isFolder: true,
      environment_path: 'url',
    };

    await factory({
      propsData: {
        environments: [mockItem],
        canReadEnvironment: true,
        canaryDeploymentFeatureId: 'canary_deployment',
        showCanaryDeploymentCallout: true,
        userCalloutsPath: '/callouts',
        lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
        helpCanaryDeploymentsPath: 'help/canary-deployments',
      },
    });

    expect(wrapper.classes()).toContain('ci-table');
  });

  it('should render deploy board container when data is provided', async () => {
    const mockItem = {
      name: 'review',
      size: 1,
      environment_path: 'url',
      logs_path: 'url',
      id: 1,
      hasDeployBoard: true,
      deployBoardData: deployBoardMockData,
      isDeployBoardVisible: true,
      isLoadingDeployBoard: false,
      isEmptyDeployBoard: false,
    };

    await factory({
      propsData: {
        environments: [mockItem],
        canCreateDeployment: false,
        canReadEnvironment: true,
        canaryDeploymentFeatureId: 'canary_deployment',
        showCanaryDeploymentCallout: true,
        userCalloutsPath: '/callouts',
        lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
        helpCanaryDeploymentsPath: 'help/canary-deployments',
      },
    });

    expect(wrapper.find('.js-deploy-board-row').exists()).toBe(true);
    expect(wrapper.find('.deploy-board-icon').exists()).toBe(true);
  });

  it('should toggle deploy board visibility when arrow is clicked', done => {
    const mockItem = {
      name: 'review',
      size: 1,
      environment_path: 'url',
      id: 1,
      hasDeployBoard: true,
      deployBoardData: {
        instances: [{ status: 'ready', tooltip: 'foo' }],
        abort_url: 'url',
        rollback_url: 'url',
        completion: 100,
        is_completed: true,
      },
      isDeployBoardVisible: false,
    };

    eventHub.$on('toggleDeployBoard', env => {
      expect(env.id).toEqual(mockItem.id);
      done();
    });

    factory({
      propsData: {
        environments: [mockItem],
        canReadEnvironment: true,
        canaryDeploymentFeatureId: 'canary_deployment',
        showCanaryDeploymentCallout: true,
        userCalloutsPath: '/callouts',
        lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
        helpCanaryDeploymentsPath: 'help/canary-deployments',
      },
    });

    wrapper.find('.deploy-board-icon').trigger('click');
  });

  it('should render canary callout', async () => {
    const mockItem = {
      name: 'review',
      folderName: 'review',
      size: 3,
      isFolder: true,
      environment_path: 'url',
      showCanaryCallout: true,
    };

    await factory({
      propsData: {
        environments: [mockItem],
        canCreateDeployment: false,
        canReadEnvironment: true,
        canaryDeploymentFeatureId: 'canary_deployment',
        showCanaryDeploymentCallout: true,
        userCalloutsPath: '/callouts',
        lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
        helpCanaryDeploymentsPath: 'help/canary-deployments',
      },
    });

    expect(wrapper.find('.canary-deployment-callout').exists()).toBe(true);
  });

  it('should render the alert if there is one', async () => {
    const mockItem = {
      name: 'review',
      size: 1,
      environment_path: 'url',
      logs_path: 'url',
      id: 1,
      hasDeployBoard: false,
      has_opened_alert: true,
    };

    await factory(
      {
        propsData: {
          environments: [mockItem],
          canReadEnvironment: true,
          canaryDeploymentFeatureId: 'canary_deployment',
          showCanaryDeploymentCallout: true,
          userCalloutsPath: '/callouts',
          lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
          helpCanaryDeploymentsPath: 'help/canary-deployments',
        },
      },
      shallowMount,
    );

    expect(wrapper.find(EnvironmentAlert).exists()).toBe(true);
  });
});
