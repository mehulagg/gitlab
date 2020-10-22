import { shallowMount } from '@vue/test-utils';
import { GlIcon, GlPopover, GlLink } from '@gitlab/ui';
import geoNodeReplicationStatusComponent from 'ee/geo_nodes/components/geo_node_replication_status.vue';
import {
  REPLICATION_STATUS_CLASS,
  REPLICATION_STATUS_ICON,
  REPLICATION_PAUSE_URL,
} from 'ee/geo_nodes/constants';
import { mockNode } from '../mock_data';

describe('GeoNodeReplicationStatusComponent', () => {
  let wrapper;

  const defaultProps = {
    node: mockNode,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(geoNodeReplicationStatusComponent, {
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

  const findStatusPill = () => wrapper.find('.rounded-pill');
  const findStatusIcon = () => findStatusPill().find(GlIcon);
  const findStatusText = () => findStatusPill().find('.status-text');
  const findHelpIcon = () => wrapper.find({ ref: 'replicationStatusHelp' });
  const findGlPopover = () => wrapper.find(GlPopover);
  const findPopoverText = () => findGlPopover().find('p');
  const findPopoverLink = () => findGlPopover().find(GlLink);

  describe.each`
    enabled  | replicationStatusCssClass            | nodeReplicationStatusIcon           | nodeReplicationStatusText
    ${true}  | ${REPLICATION_STATUS_CLASS.enabled}  | ${REPLICATION_STATUS_ICON.enabled}  | ${'Replication enabled'}
    ${false} | ${REPLICATION_STATUS_CLASS.disabled} | ${REPLICATION_STATUS_ICON.disabled} | ${'Replication paused'}
  `(
    `computed properties`,
    ({
      enabled,
      replicationStatusCssClass,
      nodeReplicationStatusIcon,
      nodeReplicationStatusText,
    }) => {
      beforeEach(() => {
        createComponent({
          node: { ...defaultProps.node, enabled },
        });
      });

      it(`sets background of StatusPill to ${replicationStatusCssClass} when enabled is ${enabled}`, () => {
        expect(
          findStatusPill()
            .classes()
            .join(' '),
        ).toContain(replicationStatusCssClass);
      });

      it('renders StatusPill correctly', () => {
        expect(findStatusPill().html()).toMatchSnapshot();
      });

      it(`sets StatusIcon to ${nodeReplicationStatusIcon} when enabled is ${enabled}`, () => {
        expect(findStatusIcon().attributes('name')).toBe(nodeReplicationStatusIcon);
      });

      it('renders Icon correctly', () => {
        expect(findStatusIcon().html()).toMatchSnapshot();
      });

      it(`sets replication status text to ${nodeReplicationStatusText} when enabled is ${enabled}`, () => {
        expect(findStatusText().text()).toBe(nodeReplicationStatusText);
      });
    },
  );

  describe('Helper Popover', () => {
    beforeEach(() => {
      createComponent();
    });

    it('always renders the help icon', () => {
      expect(findHelpIcon().exists()).toBeTruthy();
    });

    it('sets to question icon', () => {
      expect(findHelpIcon().attributes('name')).toBe('question');
    });

    it('renders popover always', () => {
      expect(findGlPopover().exists()).toBeTruthy();
    });

    it('always renders popover text', () => {
      expect(findPopoverText().exists()).toBeTruthy();
    });

    it('should display hint about pausing replication', () => {
      expect(findPopoverText().text()).toBe('Geo nodes are paused using a command run on the node');
    });

    it('renders popover link always', () => {
      expect(findPopoverLink().exists()).toBeTruthy();
    });

    it('link should be to HELP_NODE_HEALTH_URL', () => {
      expect(findPopoverLink().attributes('href')).toBe(REPLICATION_PAUSE_URL);
    });
  });
});
