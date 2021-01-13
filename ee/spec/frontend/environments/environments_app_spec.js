import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import CanaryDeploymentBoard from '~/environments/components/canary_deployment_callout.vue';
import DeployBoard from '~/environments/components/deploy_board.vue';
import EnvironmentsComponent from '~/environments/components/environments_app.vue';
import axios from '~/lib/utils/axios_utils';
import { environment } from './mock_data';

describe('Environment', () => {
  let mock;
  let wrapper;

  const mockData = {
    canaryDeploymentFeatureId: 'canary_deployment',
    canCreateEnvironment: true,
    canReadEnvironment: true,
    endpoint: 'environments.json',
    helpCanaryDeploymentsPath: 'help/canary-deployments',
    helpPagePath: 'help',
    lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
    newEnvironmentPath: 'environments/new',
    showCanaryDeploymentCallout: true,
    userCalloutsPath: '/callouts',
  };

  const canaryPromoKeyValue = () =>
    wrapper.find(CanaryDeploymentBoard).attributes('data-js-canary-promo-key');

  const createWrapper = () => {
    wrapper = mount(EnvironmentsComponent, { propsData: mockData });
    return axios.waitForAll();
  };

  const mockRequest = (environmentList) => {
    mock.onGet(mockData.endpoint).reply(
      200,
      {
        environments: environmentList,
        stopped_count: 1,
        available_count: 0,
      },
      {
        'X-nExt-pAge': '2',
        'x-page': '1',
        'X-Per-Page': '1',
        'X-Prev-Page': '',
        'X-TOTAL': '37',
        'X-Total-Pages': '2',
      },
    );
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe('with paginated environments', () => {
    beforeEach(() => {
      mockRequest([environment]);
      return createWrapper();
    });

    describe('deploy boards', () => {
      beforeEach(() => {
        const deployEnvironment = {
          ...environment,
          rollout_status: {
            status: 'found',
          },
        };

        mockRequest([environment, deployEnvironment]);
        return createWrapper();
      });

      it('should render deploy boards', () => {
        expect(wrapper.find(DeployBoard).exists()).toBe(true);
      });

      it('should render arrow to open deploy boards', () => {
        expect(wrapper.find('.deploy-board-icon [data-testid="chevron-down-icon"]').exists()).toBe(
          true,
        );
      });
    });

    describe('canary callout with one environment', () => {
      it('should render banner underneath first environment', () => {
        expect(canaryPromoKeyValue()).toBe('0');
      });
    });

    describe('canary callout with multiple environments', () => {
      beforeEach(() => {
        mockRequest([environment, environment, environment]);
        return createWrapper();
      });

      it('should render banner underneath second environment', () => {
        expect(canaryPromoKeyValue()).toBe('1');
      });
    });
  });
});
