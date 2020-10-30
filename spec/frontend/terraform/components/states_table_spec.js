import { GlIcon } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import StatesTable from '~/terraform/components/states_table.vue';

describe('StatesTable', () => {
  let wrapper;

  const daysAgo = days => {
    return new Date(Date.now() - 24 * 60 * 60 * 1000 * days).toDateString();
  };

  const propsData = {
    states: [
      {
        name: 'state-1',
        lockedAt: daysAgo(2),
        updatedAt: daysAgo(2),
      },
      {
        name: 'state-2',
        lockedAt: null,
        updatedAt: daysAgo(5),
      },
    ],
  };

  beforeEach(() => {
    wrapper = mount(StatesTable, { propsData });
    return wrapper.vm.$nextTick();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe('states table', () => {
    it.each`
      stateName    | locked   | lineNumber
      ${'state-1'} | ${true}  | ${0}
      ${'state-2'} | ${false} | ${1}
    `('displays state name', ({ stateName, locked, lineNumber }) => {
      const states = wrapper.findAll(
        '[data-testid="terraform-states-table"] tbody tr > td:first-child',
      );

      const state = states.at(lineNumber);

      expect(state.text()).toContain(stateName);
      expect(state.find(GlIcon).exists()).toBe(locked);
    });

    it.each`
      updateTime              | lineNumber
      ${'updated 2 days ago'} | ${0}
      ${'updated 5 days ago'} | ${1}
    `('displays update time', ({ updateTime, lineNumber }) => {
      const states = wrapper.findAll(
        '[data-testid="terraform-states-table"] tbody tr > td:nth-child(2)',
      );

      const state = states.at(lineNumber);

      expect(state.text()).toBe(updateTime);
    });
  });
});
