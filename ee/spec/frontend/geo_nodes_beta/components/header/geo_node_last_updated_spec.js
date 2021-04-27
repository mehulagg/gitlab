import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeLastUpdated from 'ee/geo_nodes_beta/components/header/geo_node_last_updated.vue';
import {
  HELP_NODE_HEALTH_URL,
  GEO_TROUBLESHOOTING_URL,
  STATUS_DELAY_THRESHOLD_MS,
} from 'ee/geo_nodes_beta/constants';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { differenceInMilliseconds } from '~/lib/utils/datetime_utility';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeLastUpdated', () => {
  let wrapper;

  // The threshold is inclusive so -1 to force stale
  const staleStatusTime = differenceInMilliseconds(STATUS_DELAY_THRESHOLD_MS) - 1;
  const nonStaleStatusTime = new Date().getTime();

  const defaultProps = {
    statusCheckTimestamp: staleStatusTime,
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

    wrapper = extendedWrapper(
      shallowMount(GeoNodeLastUpdated, {
        localVue,
        store,
        propsData: {
          ...defaultProps,
          ...props,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findMainText = () => wrapper.findByTestId('last-updated-main-text');
  const findGlIcon = () => wrapper.findComponent(GlIcon);
  const findGlPopover = () => wrapper.findComponent(GlPopover);
  const findPopoverText = () => findGlPopover().find('p');
  const findPopoverLink = () => findGlPopover().findComponent(GlLink);

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders main text correctly', () => {
        expect(findMainText().exists()).toBe(true);
        expect(findMainText().text()).toBe('Updated 10 minutes ago');
      });

      it('renders the question icon correctly', () => {
        expect(findGlIcon().exists()).toBe(true);
        expect(findGlIcon().attributes('name')).toBe('question');
      });

      it('renders the popover always', () => {
        expect(findGlPopover().exists()).toBe(true);
      });

      it('renders the popover text correctly', () => {
        expect(findPopoverText().exists()).toBe(true);
        expect(findPopoverText().text()).toBe("Node's status was updated 10 minutes ago.");
      });

      it('renders the popover link always', () => {
        expect(findPopoverLink().exists()).toBe(true);
      });
    });

    it('when sync is stale popover link renders correctly', () => {
      createComponent();

      expect(findPopoverLink().text()).toBe('Consult Geo troubleshooting information');
      expect(findPopoverLink().attributes('href')).toBe(GEO_TROUBLESHOOTING_URL);
    });

    it('when sync is not stale popover link renders correctly', () => {
      createComponent(null, { statusCheckTimestamp: nonStaleStatusTime });

      expect(findPopoverLink().text()).toBe('Learn more about Geo node statuses');
      expect(findPopoverLink().attributes('href')).toBe(HELP_NODE_HEALTH_URL);
    });
  });
});
