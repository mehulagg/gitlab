import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StageDropdownFilter from 'ee/analytics/cycle_analytics/components/stage_dropdown_filter.vue';

const stages = [
  {
    id: 1,
    title: 'Issue',
  },
  {
    id: 2,
    title: 'Plan',
  },
  {
    id: 3,
    title: 'Code',
  },
];

describe('StageDropdownFilter component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(StageDropdownFilter, {
      propsData: {
        stages,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  beforeEach(() => {
    createComponent();
  });

  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const selectDropdownItemAtIndex = (index) =>
    findDropdown().findAllComponents(GlDropdownItem).at(index).vm.$emit('click');

  describe('on stage click', () => {
    describe('clicking a selected stage', () => {
      it('should remove from selection', () => {
        selectDropdownItemAtIndex(0);

        expect(wrapper.emitted().selected).toEqual([[[stages[1], stages[2]]]]);
      });
    });

    describe('clicking a deselected stage', () => {
      beforeEach(() => {
        selectDropdownItemAtIndex(0);
      });

      it('should add to selection', () => {
        selectDropdownItemAtIndex(0);

        expect(wrapper.emitted().selected).toEqual([
          [[stages[1], stages[2]]],
          [[stages[1], stages[2], stages[0]]],
        ]);
      });
    });
  });
});
