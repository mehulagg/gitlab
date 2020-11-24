import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeLastUpdated from 'ee/geo_nodes/components/geo_node_last_updated.vue';
import {
  HELP_NODE_HEALTH_URL,
  GEO_TROUBLESHOOTING_URL,
  STATUS_DELAY_THRESHOLD_MS,
} from 'ee/geo_nodes/constants';
import { differenceInMilliseconds } from '~/lib/utils/datetime_utility';

describe('GeoNodeLastUpdated', () => {
  let wrapper;

  const staleStatusTime = differenceInMilliseconds(STATUS_DELAY_THRESHOLD_MS);
  const nonStaleStatusTime = new Date().getTime();

  const defaultProps = {
    statusCheckTimestamp: staleStatusTime,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(GeoNodeLastUpdated, {
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

  const findMainText = () => wrapper.find('[data-testid="nodeLastUpdateMainText"]');
  const findGlIcon = () => wrapper.find(GlIcon);
  const findGlPopover = () => wrapper.find(GlPopover);
  const findPopoverText = () => findGlPopover().find('p');
  const findPopoverLink = () => findGlPopover().find(GlLink);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('Main Text', () => {
      it('renders always', () => {
        expect(findMainText().exists()).toBeTruthy();
      });

      it('should properly display time ago', () => {
        expect(findMainText().text()).toBe('Updated 10 minutes ago');
      });
    });

    describe('Question Icon', () => {
      it('renders always', () => {
        expect(findGlIcon().exists()).toBeTruthy();
      });

      it('sets to question icon', () => {
        expect(findGlIcon().attributes('name')).toBe('question');
      });
    });

    it('renders popover always', () => {
      expect(findGlPopover().exists()).toBeTruthy();
    });

    describe('Popover Text', () => {
      it('renders always', () => {
        expect(findPopoverText().exists()).toBeTruthy();
      });

      it('should properly display time ago', () => {
        expect(findPopoverText().text()).toBe("Node's status was updated 10 minutes ago.");
      });
    });

    describe('Popover Link', () => {
      describe('when sync is stale', () => {
        it('text should mention troubleshooting', () => {
          expect(findPopoverLink().text()).toBe('Consult Geo troubleshooting information');
        });

        it('link should be to GEO_TROUBLESHOOTING_URL', () => {
          expect(findPopoverLink().attributes('href')).toBe(GEO_TROUBLESHOOTING_URL);
        });
      });

      describe('when sync is not stale', () => {
        beforeEach(() => {
          createComponent({ statusCheckTimestamp: nonStaleStatusTime });
        });

        it('text should not mention troubleshooting', () => {
          expect(findPopoverLink().text()).toBe('Learn more about Geo node statuses');
        });

        it('link should be to HELP_NODE_HEALTH_URL', () => {
          expect(findPopoverLink().attributes('href')).toBe(HELP_NODE_HEALTH_URL);
        });
      });
    });

    it('renders popover link always', () => {
      expect(findPopoverLink().exists()).toBeTruthy();
    });
  });
});
