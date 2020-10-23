import { shallowMount } from '@vue/test-utils';

import GridColumnHeading from 'ee/compliance_dashboard/components/shared/grid_column_heading.vue';

describe('GridColumnHeading component', () => {
  let wrapper;

  const createComponent = heading => {
    return shallowMount(GridColumnHeading, {
      propsData: { heading },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('behaviour', () => {
    beforeEach(() => {
      wrapper = createComponent('Test heading');
    });

    it('matches the screenshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('has the the heading text', () => {
      expect(wrapper.text()).toEqual('Test heading');
    });
  });
});
