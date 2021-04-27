import { GlIcon, GlBadge } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeHealthStatus from 'ee/geo_nodes_beta/components/header/geo_node_health_status.vue';
import { HEALTH_STATUS_UI } from 'ee/geo_nodes_beta/constants';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES } from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeHealthStatus', () => {
  let wrapper;

  const defaultProps = {
    status: 'Healthy',
  };

  const createComponent = (initialState, props) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
    });

    wrapper = shallowMount(GeoNodeHealthStatus, {
      localVue,
      store,
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoStatusBadge = () => wrapper.findComponent(GlBadge);
  const findGeoStatusIcon = () => wrapper.findComponent(GlIcon);
  const findGeoStatusText = () => wrapper.find('span');

  describe.each`
    status         | uiData
    ${'Healthy'}   | ${HEALTH_STATUS_UI.healthy}
    ${'Unhealthy'} | ${HEALTH_STATUS_UI.unhealthy}
    ${'Disabled'}  | ${HEALTH_STATUS_UI.disabled}
    ${'Unknown'}   | ${HEALTH_STATUS_UI.unknown}
    ${'Offline'}   | ${HEALTH_STATUS_UI.offline}
  `(`template`, ({ status, uiData }) => {
    beforeEach(() => {
      createComponent(null, { status });
    });

    describe(`when status is ${status}`, () => {
      it(`renders badge variant to ${uiData.variant}`, () => {
        expect(findGeoStatusBadge().attributes('variant')).toBe(uiData.variant);
      });

      it(`renders icon to ${uiData.icon}`, () => {
        expect(findGeoStatusIcon().attributes('name')).toBe(uiData.icon);
      });

      it(`renders status text to ${status}`, () => {
        expect(findGeoStatusText().text()).toBe(status);
      });
    });
  });
});
