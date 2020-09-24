import { shallowMount } from '@vue/test-utils';
import { GlPopover, GlLink, GlSprintf } from '@gitlab/ui';

import GeoNodeDetailItemComponent from 'ee/geo_nodes/components/geo_node_detail_item.vue';
import GeoNodeSyncSettings from 'ee/geo_nodes/components/geo_node_sync_settings.vue';
import GeoNodeEventStatus from 'ee/geo_nodes/components/geo_node_event_status.vue';
import GeoNodeSyncProgress from 'ee/geo_nodes/components/geo_node_sync_progress.vue';

import { VALUE_TYPE, CUSTOM_TYPE, REPLICATION_HELP_URL } from 'ee/geo_nodes/constants';
import { rawMockNodeDetails } from '../mock_data';

describe('GeoNodeDetailItemComponent', () => {
  let wrapper;

  const defaultProps = {
    itemTitle: 'GitLab version',
    cssClass: 'node-version',
    itemValue: '10.4.0-pre',
    successLabel: 'Synced',
    failureLabel: 'Failed',
    neutralLabel: 'Out of sync',
    itemValueType: VALUE_TYPE.PLAIN,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(GeoNodeDetailItemComponent, {
      stubs: { GlSprintf },
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders container elements correctly', () => {
      expect(wrapper.find('.node-detail-item').exists()).toBeTruthy();
      expect(wrapper.findAll('.node-detail-title')).not.toHaveLength(0);
      expect(
        wrapper
          .find('.node-detail-title')
          .text()
          .trim(),
      ).toBe('GitLab version');
    });

    describe('when plain text value', () => {
      it('renders plain item value', () => {
        expect(wrapper.findAll('.node-detail-value')).not.toHaveLength(0);
        expect(
          wrapper
            .find('.node-detail-value')
            .text()
            .trim(),
        ).toBe('10.4.0-pre');
      });

      it('does not render graph item', () => {
        expect(wrapper.find(GeoNodeSyncProgress).exists()).toBeFalsy();
      });
    });

    describe('when graph item value', () => {
      beforeEach(() => {
        createComponent({
          itemValueType: VALUE_TYPE.GRAPH,
          itemValue: { successCount: 5, failureCount: 3, totalCount: 10 },
        });
      });

      it('renders graph item', () => {
        expect(wrapper.find(GeoNodeSyncProgress).exists()).toBeTruthy();
      });
    });

    describe('when custom type is sync', () => {
      beforeEach(() => {
        createComponent({
          itemValueType: VALUE_TYPE.CUSTOM,
          customType: CUSTOM_TYPE.SYNC,
          itemValue: {
            namespaces: rawMockNodeDetails.namespaces,
            lastEvent: {
              id: rawMockNodeDetails.last_event_id,
              timeStamp: rawMockNodeDetails.last_event_timestamp,
            },
            cursorLastEvent: {
              id: rawMockNodeDetails.cursor_last_event_id,
              timeStamp: rawMockNodeDetails.cursor_last_event_timestamp,
            },
          },
        });
      });

      it('renders sync settings item value', () => {
        expect(wrapper.find(GeoNodeSyncSettings).exists()).toBeTruthy();
      });

      it('does not render graph item', () => {
        expect(wrapper.find(GeoNodeSyncProgress).exists()).toBeFalsy();
      });
    });

    describe('when custom type is event', () => {
      beforeEach(() => {
        createComponent({
          itemValueType: VALUE_TYPE.CUSTOM,
          customType: CUSTOM_TYPE.EVENT,
          itemValue: {
            eventId: rawMockNodeDetails.last_event_id,
            eventTimeStamp: rawMockNodeDetails.last_event_timestamp,
          },
        });
      });

      it('renders event status item value', () => {
        expect(wrapper.find(GeoNodeEventStatus).exists()).toBeTruthy();
      });

      it('does not render graph item', () => {
        expect(wrapper.find(GeoNodeSyncProgress).exists()).toBeFalsy();
      });
    });
  });

  describe('itemEnabled', () => {
    describe('when false', () => {
      beforeEach(() => {
        createComponent({
          itemEnabled: false,
        });
      });

      it('renders synchronization disabled text', () => {
        expect(
          wrapper
            .find({ ref: 'disabledText' })
            .text()
            .trim(),
        ).toBe('Synchronization disabled');
      });

      it('renders GlPopover', () => {
        expect(wrapper.find(GlPopover).exists()).toBeTruthy();
      });

      it('renders disabled text', () => {
        expect(wrapper.find(GlPopover).text()).toContain(
          `Synchronization of ${defaultProps.itemTitle.toLowerCase()} is disabled.`,
        );
      });

      it('renders link to replication help documentation in popover', () => {
        const popoverLink = wrapper.find(GlPopover).find(GlLink);

        expect(popoverLink.exists()).toBeTruthy();
        expect(popoverLink.text()).toBe('Learn how to enable synchronization');
        expect(popoverLink.attributes('href')).toBe(REPLICATION_HELP_URL);
      });
    });

    describe('when true', () => {
      beforeEach(() => {
        createComponent({
          itemEnabled: true,
        });
      });

      it('does not render synchronization disabled text', () => {
        expect(wrapper.find('.node-detail-item').text()).not.toContain('Synchronization disabled');
      });

      it('does not render GlPopover', () => {
        expect(wrapper.find(GlPopover).exists()).toBeFalsy();
      });
    });
  });
});
