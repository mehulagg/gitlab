import { shallowMount } from '@vue/test-utils';
import $ from 'jquery';
import 'bootstrap';
import '~/gl_dropdown';
import StageDropdownFilter from 'ee/analytics/cycle_analytics/components/stage_dropdown_filter.vue';

jest.mock('~/api', () => ({
  groupProjects: jest.fn(),
}));

const stages = [
  {
    title: 'Issue',
  },
  {
    title: 'Plan',
  },
  {
    title: 'Code',
  },
];

describe('StageDropdownFilter component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(StageDropdownFilter, {
      sync: false,
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

  const findDropdown = () => wrapper.find('.dropdown');
  const openDropdown = () => {
    $(findDropdown().element)
      .parent()
      .trigger('shown.bs.dropdown');
  };
  const findDropdownItems = () => findDropdown().findAll('a');

  describe('on stage click', () => {
    beforeEach(() => {
      openDropdown();

      return wrapper.vm.$nextTick();
    });

    describe('clicking a selected stage', () => {
      it('should remove from selection', () => {
        const item = findDropdownItems().at(0);

        item.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emittedByOrder()).toEqual([
            {
              name: 'selected',
              args: [[stages[1], stages[2]]],
            },
          ]);
        });
      });
    });

    describe('clicking a deselected stage', () => {
      it('should add to selection', () => {
        findDropdownItems()
          .at(0)
          .trigger('click');

        return wrapper.vm
          .$nextTick()
          .then(() => {
            findDropdownItems()
              .at(0)
              .trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            expect(wrapper.emittedByOrder()).toEqual([
              {
                name: 'selected',
                args: [[stages[1], stages[2]]],
              },
              {
                name: 'selected',
                args: [[stages[1], stages[2], stages[0]]],
              },
            ]);
          });
      });
    });
  });
});
