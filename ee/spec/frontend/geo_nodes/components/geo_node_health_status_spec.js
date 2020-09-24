import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import geoNodeHealthStatusComponent from 'ee/geo_nodes/components/geo_node_health_status.vue';
import { HEALTH_STATUS_ICON, HEALTH_STATUS_CLASS } from 'ee/geo_nodes/constants';
import { mockNodeDetails } from '../mock_data';

describe('GeoNodeHealthStatusComponent', () => {
  let wrapper;

  const defaultProps = {
    status: mockNodeDetails.health,
    statusCheckTimestamp: mockNodeDetails.statusCheckTimestamp,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(geoNodeHealthStatusComponent, {
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

  describe.each`
    status         | healthCssClass                   | statusIconName
    ${'Healthy'}   | ${HEALTH_STATUS_CLASS.healthy}   | ${HEALTH_STATUS_ICON.healthy}
    ${'Unhealthy'} | ${HEALTH_STATUS_CLASS.unhealthy} | ${HEALTH_STATUS_ICON.unhealthy}
    ${'Disabled'}  | ${HEALTH_STATUS_CLASS.disabled}  | ${HEALTH_STATUS_ICON.disabled}
    ${'Unknown'}   | ${HEALTH_STATUS_CLASS.unknown}   | ${HEALTH_STATUS_ICON.unknown}
    ${'Offline'}   | ${HEALTH_STATUS_CLASS.offline}   | ${HEALTH_STATUS_ICON.offline}
  `(`computed properties`, ({ status, healthCssClass, statusIconName }) => {
    beforeEach(() => {
      createComponent({ status });
    });

    it(`sets background of StatusPill to ${healthCssClass} when status is ${status}`, () => {
      expect(
        findStatusPill()
          .classes()
          .join(' '),
      ).toContain(healthCssClass);
    });

    it('renders StatusPill correctly', () => {
      expect(findStatusPill().html()).toMatchSnapshot();
    });

    it(`sets StatusIcon to ${statusIconName} when status is ${status}`, () => {
      expect(findStatusIcon().attributes('name')).toBe(statusIconName);
    });

    it('renders Icon correctly', () => {
      expect(findStatusIcon().html()).toMatchSnapshot();
    });
  });
});
