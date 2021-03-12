import { GlIcon, GlPopover, GlLink, GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import GeoNodeReplicationDetails from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_details.vue';
import GeoNodeReplicationDetailsDesktop from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_details_desktop.vue';
import GeoNodeReplicationDetailsMobile from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_details_mobile.vue';
import { GEO_REPLICATION_TYPES_URL } from 'ee/geo_nodes_beta/constants';
import { MOCK_NODES, MOCK_REPLICABLE_TYPES } from 'ee_jest/geo_nodes_beta/mock_data';

Vue.use(Vuex);

describe('GeoNodeReplicationDetails', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (initialState, props, getters) => {
    const store = new Vuex.Store({
      state: {
        replicableTypes: [],
        ...initialState,
      },
      getters: {
        syncInfo: () => () => [],
        verificationInfo: () => () => [],
        ...getters,
      },
    });

    wrapper = shallowMount(GeoNodeReplicationDetails, {
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

  const findGeoMobileReplicationDetails = () =>
    wrapper.findComponent(GeoNodeReplicationDetailsMobile);
  const findGeoDesktopReplicationDetails = () =>
    wrapper.findComponent(GeoNodeReplicationDetailsDesktop);
  const findGlIcon = () => wrapper.findComponent(GlIcon);
  const findGlPopover = () => wrapper.findComponent(GlPopover);
  const findGlPopoverLink = () => findGlPopover().findComponent(GlLink);
  const findCollapseButton = () => wrapper.findComponent(GlButton);

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the question icon correctly', () => {
        expect(findGlIcon().exists()).toBe(true);
        expect(findGlIcon().props('name')).toBe('question');
      });

      it('renders the GlPopover always', () => {
        expect(findGlPopover().exists()).toBe(true);
      });

      it('renders the popover link correctly', () => {
        expect(findGlPopoverLink().exists()).toBe(true);
        expect(findGlPopoverLink().attributes('href')).toBe(GEO_REPLICATION_TYPES_URL);
      });
    });

    describe('when un-collapsed', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the collapse button correctly', () => {
        expect(findCollapseButton().exists()).toBe(true);
        expect(findCollapseButton().attributes('icon')).toBe('chevron-down');
      });

      it('renders mobile replication details with correct visibility class', () => {
        expect(findGeoMobileReplicationDetails().exists()).toBe(true);
        expect(findGeoMobileReplicationDetails().classes()).toStrictEqual(['gl-md-display-none!']);
      });

      it('renders desktop details with correct visibility class', () => {
        expect(findGeoDesktopReplicationDetails().exists()).toBe(true);
        expect(findGeoDesktopReplicationDetails().classes()).toStrictEqual([
          'gl-display-none',
          'gl-md-display-block',
        ]);
      });
    });

    describe('when collapsed', () => {
      beforeEach(() => {
        createComponent();
        findCollapseButton().vm.$emit('click');
      });

      it('renders the collapse button correctly', () => {
        expect(findCollapseButton().exists()).toBe(true);
        expect(findCollapseButton().attributes('icon')).toBe('chevron-right');
      });

      it('does not render mobile replication details', () => {
        expect(findGeoMobileReplicationDetails().exists()).toBe(false);
      });

      it('does not render desktop replication details', () => {
        expect(findGeoDesktopReplicationDetails().exists()).toBe(false);
      });
    });

    describe.each`
      description                    | mockSyncData                                                                                                                                    | mockVerificationData                                                                                                                            | expectedProps
      ${'with no data'}              | ${[]}                                                                                                                                           | ${[]}                                                                                                                                           | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, component: MOCK_REPLICABLE_TYPES[0].titlePlural, syncValues: null, verificationValues: null }]}
      ${'with no verification data'} | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, title: MOCK_REPLICABLE_TYPES[0].titlePlural, values: { total: 100, success: 0 } }]} | ${[]}                                                                                                                                           | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, component: MOCK_REPLICABLE_TYPES[0].titlePlural, syncValues: { total: 100, success: 0 }, verificationValues: null }]}
      ${'with no sync data'}         | ${[]}                                                                                                                                           | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, title: MOCK_REPLICABLE_TYPES[0].titlePlural, values: { total: 50, success: 50 } }]} | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, component: MOCK_REPLICABLE_TYPES[0].titlePlural, syncValues: null, verificationValues: { total: 50, success: 50 } }]}
      ${'with all data'}             | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, title: MOCK_REPLICABLE_TYPES[0].titlePlural, values: { total: 100, success: 0 } }]} | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, title: MOCK_REPLICABLE_TYPES[0].titlePlural, values: { total: 50, success: 50 } }]} | ${[{ dataTypeTitle: MOCK_REPLICABLE_TYPES[0].dataTypeTitle, component: MOCK_REPLICABLE_TYPES[0].titlePlural, syncValues: { total: 100, success: 0 }, verificationValues: { total: 50, success: 50 } }]}
    `('$description', ({ mockSyncData, mockVerificationData, expectedProps }) => {
      beforeEach(() => {
        createComponent({ replicableTypes: [MOCK_REPLICABLE_TYPES[0]] }, null, {
          syncInfo: () => () => mockSyncData,
          verificationInfo: () => () => mockVerificationData,
        });
      });

      it('passes the correct props to the mobile replication details', () => {
        expect(findGeoMobileReplicationDetails().props('replicationItems')).toStrictEqual(
          expectedProps,
        );
      });

      it('passes the correct props to the desktop replication details', () => {
        expect(findGeoDesktopReplicationDetails().props('replicationItems')).toStrictEqual(
          expectedProps,
        );
      });
    });
  });
});
