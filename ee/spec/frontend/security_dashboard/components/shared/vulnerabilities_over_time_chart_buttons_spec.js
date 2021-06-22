import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import Vue from 'vue';
import component from 'ee/security_dashboard/components/shared/vulnerabilities_over_time_chart_buttons.vue';
import { DAYS } from 'ee/security_dashboard/store/constants';

const localVue = createLocalVue();

describe('Vulnerability Chart Buttons', () => {
  let wrapper;
  const Component = Vue.extend(component);
  const days = Object.values(DAYS);

  const createWrapper = (props = {}, mountfn = shallowMount) => {
    wrapper = mountfn(localVue.extend(Component), {
      propsData: { days, ...props },
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when rendering the buttons', () => {
    it('should render with 90 days selected', () => {
      const activeDay = DAYS.ninety;
      createWrapper({ activeDay });

      const activeButton = wrapper.find('[data-days="90"].selected');

      expect(activeButton.attributes('data-days')).toMatch('90');
    });

    it('should render with 60 days selected', () => {
      const activeDay = DAYS.sixty;
      createWrapper({ activeDay });

      const activeButton = wrapper.find('[data-days="60"].selected');

      expect(activeButton.attributes('data-days')).toMatch('60');
    });

    it('should render with 30 days selected', () => {
      const activeDay = DAYS.thirty;
      createWrapper({ activeDay });

      const activeButton = wrapper.find('[data-days="30"].selected');

      expect(activeButton.attributes('data-days')).toMatch('30');
    });
  });

  describe('when clicking the button', () => {
    const activeDay = DAYS.thirty;

    beforeEach(() => {
      createWrapper({ activeDay }, mount);
    });

    it('should call the clickHandler', () => {
      jest.spyOn(wrapper.vm, 'clickHandler');
      wrapper.find('[data-days="30"].selected').trigger('click', DAYS.thirty);

      expect(wrapper.vm.clickHandler).toHaveBeenCalledWith(DAYS.thirty);
    });

    it('should emit a click event', () => {
      wrapper.find('[data-days="30"].selected').trigger('click', DAYS.thirty);

      expect(wrapper.emitted().click[0]).toEqual([DAYS.thirty]);
    });
  });
});
