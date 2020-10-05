import { shallowMount } from '@vue/test-utils';
import TimeAgo from 'ee/vue_shared/dashboards/components/time_ago.vue';
import { differenceInMilliseconds } from '~/lib/utils/datetime_utility';

describe('time ago component', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(TimeAgo, {
      propsData: {
        time: new Date(differenceInMilliseconds(86400000)).toISOString(),
        tooltipText: 'Finished',
      },
    });
  });

  describe('render', () => {
    it('renders clock icon', () => {
      expect(wrapper.find('.js-dashboard-project-clock-icon').exists()).toBe(true);
    });

    it('renders time ago of finished time', () => {
      const timeago = '1 day ago';
      const container = wrapper.element.querySelector('.js-dashboard-project-time-ago');

      expect(container.innerText.trim()).toBe(timeago);
    });
  });
});
