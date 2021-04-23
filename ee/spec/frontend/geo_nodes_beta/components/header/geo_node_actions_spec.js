import { shallowMount } from '@vue/test-utils';
import GeoNodeActions from 'ee/geo_nodes_beta/components/header/geo_node_actions.vue';
import GeoNodeActionsDesktop from 'ee/geo_nodes_beta/components/header/geo_node_actions_desktop.vue';
import GeoNodeActionsMobile from 'ee/geo_nodes_beta/components/header/geo_node_actions_mobile.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';

describe('GeoNodeActions', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (props) => {
    wrapper = shallowMount(GeoNodeActions, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoMobileActions = () => wrapper.find(GeoNodeActionsMobile);
  const findGeoDesktopActions = () => wrapper.find(GeoNodeActionsDesktop);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders mobile actions with correct visibility class always', () => {
      expect(findGeoMobileActions().exists()).toBe(true);
      expect(findGeoMobileActions().classes()).toStrictEqual(['gl-lg-display-none']);
    });

    it('renders desktop actions with correct visibility class always', () => {
      expect(findGeoDesktopActions().exists()).toBe(true);
      expect(findGeoDesktopActions().classes()).toStrictEqual([
        'gl-display-none',
        'gl-lg-display-flex',
      ]);
    });
  });
});
