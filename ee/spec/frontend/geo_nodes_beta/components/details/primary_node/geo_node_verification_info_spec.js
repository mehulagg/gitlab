import { GlCard, GlIcon, GlPopover, GlLink } from '@gitlab/ui';
import { createLocalVue, mount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeProgressBar from 'ee/geo_nodes_beta/components/details/geo_node_progress_bar.vue';
import GeoNodeVerificationInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_verification_info.vue';
import { HELP_INFO_URL } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
  MOCK_PRIMARY_VERIFICATION_INFO,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeVerificationInfo', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (initialState, props) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
      getters: {
        verificationInfo: () => () => MOCK_PRIMARY_VERIFICATION_INFO,
      },
    });

    wrapper = mount(GeoNodeVerificationInfo, {
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
    wrapper = null;
  });

  const findGlCard = () => wrapper.find(GlCard);
  const findGlIcon = () => wrapper.find(GlIcon);
  const findGlPopover = () => wrapper.find(GlPopover);
  const findGlPopoverLink = () => findGlPopover().find(GlLink);
  const findGeoNodeProgressBarTitles = () =>
    wrapper.findAll('[data-testid="verificationBarTitle"]');
  const findGeoNodeProgressBars = () => wrapper.findAll(GeoNodeProgressBar);

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the details card', () => {
        expect(findGlCard().exists()).toBe(true);
      });

      it('renders the question icon correctly', () => {
        expect(findGlIcon().exists()).toBe(true);
        expect(findGlIcon().find('use').attributes('href')).toBe('#question');
      });

      it('renders the GlPopover always', () => {
        expect(findGlPopover().exists()).toBeTruthy();
      });

      it('renders the popover link correctly', () => {
        expect(findGlPopoverLink().exists()).toBeTruthy();
        expect(findGlPopoverLink().attributes('href')).toBe(HELP_INFO_URL);
      });

      it('renders a progress bar for each verification replicable', () => {
        expect(findGeoNodeProgressBars()).toHaveLength(MOCK_PRIMARY_VERIFICATION_INFO.length);
      });

      it('renders progress bar title correctly', () => {
        expect(findGeoNodeProgressBarTitles().wrappers.map((w) => w.text())).toEqual(
          MOCK_PRIMARY_VERIFICATION_INFO.map((vI) => `${vI.title} checksum progress`),
        );
      });
    });
  });
});
