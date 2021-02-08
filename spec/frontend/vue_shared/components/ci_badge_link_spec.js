import { mount } from '@vue/test-utils';
import CiBadge from '~/vue_shared/components/ci_badge_link.vue';
import CiIcon from '~/vue_shared/components/ci_icon.vue';

describe('CI Badge Link Component', () => {
  let wrapper;

  const statuses = {
    canceled: {
      text: 'canceled',
      label: 'canceled',
      group: 'canceled',
      icon: 'status_canceled',
      details_path: 'status/canceled',
    },
    created: {
      text: 'created',
      label: 'created',
      group: 'created',
      icon: 'status_created',
      details_path: 'status/created',
    },
    failed: {
      text: 'failed',
      label: 'failed',
      group: 'failed',
      icon: 'status_failed',
      details_path: 'status/failed',
    },
    manual: {
      text: 'manual',
      label: 'manual action',
      group: 'manual',
      icon: 'status_manual',
      details_path: 'status/manual',
    },
    pending: {
      text: 'pending',
      label: 'pending',
      group: 'pending',
      icon: 'status_pending',
      details_path: 'status/pending',
    },
    running: {
      text: 'running',
      label: 'running',
      group: 'running',
      icon: 'status_running',
      details_path: 'status/running',
    },
    skipped: {
      text: 'skipped',
      label: 'skipped',
      group: 'skipped',
      icon: 'status_skipped',
      details_path: 'status/skipped',
    },
    success_warining: {
      text: 'passed',
      label: 'passed',
      group: 'success-with-warnings',
      icon: 'status_warning',
      details_path: 'status/warning',
    },
    success: {
      text: 'passed',
      label: 'passed',
      group: 'passed',
      icon: 'status_success',
      details_path: 'status/passed',
    },
  };

  const findIcon = () => wrapper.findComponent(CiIcon);

  const createComponent = (props) => {
    wrapper = mount(CiBadge, { propsData: { ...props } });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render each status badge', () => {
    Object.keys(statuses).map((status) => {
      createComponent({ status: statuses[status] });

      expect(wrapper.attributes('href')).toEqual(statuses[status].details_path);
      expect(wrapper.text()).toEqual(statuses[status].text);
      expect(wrapper.classes()).toContain('ci-status');
      expect(wrapper.classes()).toContain(`ci-${statuses[status].group}`);
      expect(findIcon().exists()).toBe(true);
    });
  });

  it('should not render label', () => {
    createComponent({ status: statuses.canceled, showText: false });

    expect(wrapper.text()).toEqual('');
  });
});
