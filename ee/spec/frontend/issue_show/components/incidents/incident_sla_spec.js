import { shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import { GlLoadingIcon } from '@gitlab/ui';
import IncidentSla from 'ee/issue_show/components/incidents/incident_sla.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { formatTime } from '~/lib/utils/datetime_utility';

jest.mock('~/lib/utils/datetime_utility');

const defaultProvide = { fullPath: 'test', iid: 1, slaFeatureAvailable: true };

describe('Highlight Bar', () => {
  let wrapper;

  const mountComponent = options => {
    wrapper = shallowMount(
      IncidentSla,
      merge(
        {
          data() {
            return { slaDueAt: '2020-01-01T00:00:00.000Z' };
          },
          provide: { ...defaultProvide },
          mocks: { $apollo: { queries: { slaDueAt: { loading: false } } } },
        },
        options,
      ),
    );
  };

  beforeEach(() => {
    formatTime.mockImplementation(() => '12:34:56');
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findTimer = () => wrapper.find(TimeAgoTooltip);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  it('renders a loading spinner when loading', () => {
    mountComponent({ mocks: { $apollo: { queries: { slaDueAt: { loading: true } } } } });

    expect(findLoadingIcon().exists()).toBe(true);
  });

  it('does not render an SLA when no sla is present', () => {
    mountComponent({
      data() {
        return { slaDueAt: null };
      },
    });

    expect(findTimer().exists()).toBe(false);
  });

  it('renders an incident SLA when sla is present', () => {
    mountComponent();

    expect(findTimer().exists()).toBe(true);
    expect(findTimer().text()).toBe('12:34');
  });

  it('renders a component when feature is available', () => {
    mountComponent();

    expect(wrapper.exists()).toBe(true);
  });

  it('renders a blank component when feature is not available', () => {
    mountComponent({
      provide: {
        ...defaultProvide,
        slaFeatureAvailable: false,
      },
    });

    expect(wrapper.html()).toBe('');
  });
});
