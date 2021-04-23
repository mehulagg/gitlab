import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeLastUpdated from 'ee/geo_nodes_beta/components/header/geo_node_last_updated.vue';
import {
  HELP_NODE_HEALTH_URL,
  GEO_TROUBLESHOOTING_URL,
  STATUS_DELAY_THRESHOLD_MS,
} from 'ee/geo_nodes_beta/constants';
import { differenceInMilliseconds } from '~/lib/utils/datetime_utility';

describe('GeoNodeLastUpdated', () => {
  let wrapper;

  // The threshold is inclusive so -1 to force stale
  const staleStatusTime = differenceInMilliseconds(STATUS_DELAY_THRESHOLD_MS) - 1;
  const nonStaleStatusTime = new Date().getTime();

  const defaultProps = {
    statusCheckTimestamp: staleStatusTime,
  };

  const createComponent = (props) => {
    wrapper = shallowMount(GeoNodeLastUpdated, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findMainText = () => wrapper.find('[data-testid="last-updated-main-text"]');
  const findGlIcon = () => wrapper.find(GlIcon);
  const findGlPopover = () => wrapper.find(GlPopover);
  const findPopoverText = () => findGlPopover().find('p');
  const findPopoverLink = () => findGlPopover().find(GlLink);

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
        expect(findPopoverText().exists()).toBeTruthy();
        expect(findPopoverText().text()).toBe("Node's status was updated 10 minutes ago.");
      });

      it('renders the popover link always', () => {
        expect(findPopoverLink().exists()).toBeTruthy();
      });
    });

    it('when sync is stale popover link renders correctly', () => {
      createComponent();

      expect(findPopoverLink().text()).toBe('Consult Geo troubleshooting information');
      expect(findPopoverLink().attributes('href')).toBe(GEO_TROUBLESHOOTING_URL);
    });

    it('when sync is not stale popover link renders correctly', () => {
      createComponent({ statusCheckTimestamp: nonStaleStatusTime });

      expect(findPopoverLink().text()).toBe('Learn more about Geo node statuses');
      expect(findPopoverLink().attributes('href')).toBe(HELP_NODE_HEALTH_URL);
    });
  });
});
