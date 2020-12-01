import { GlDropdownItem, GlSegmentedControl } from '@gitlab/ui';
import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Vuex from 'vuex';
import LabelsSelector from 'ee/analytics/cycle_analytics/components/labels_selector.vue';
import TasksByTypeFilters from 'ee/analytics/cycle_analytics/components/tasks_by_type/tasks_by_type_filters.vue';
import {
  TASKS_BY_TYPE_SUBJECT_ISSUE,
  TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST,
  TASKS_BY_TYPE_FILTERS,
} from 'ee/analytics/cycle_analytics/constants';
import createStore from 'ee/analytics/cycle_analytics/store';
import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import waitForPromises from 'helpers/wait_for_promises';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { groupLabels } from '../../mock_data';

const selectedLabelIds = [groupLabels[0].id];

const findSubjectFilters = ctx => ctx.find(GlSegmentedControl);
const findSelectedSubjectFilters = ctx => findSubjectFilters(ctx).attributes('checked');
const findDropdownLabels = ctx => ctx.find(LabelsSelector).findAll(GlDropdownItem);

const selectLabelAtIndex = (ctx, index) => {
  findDropdownLabels(ctx)
    .at(index)
    .trigger('click');

  return waitForPromises();
};

const mockGroupLabelsRequest = () => new MockAdapter(axios).onGet().reply(200, groupLabels);

let store = null;
const localVue = createLocalVue();
localVue.use(Vuex);

jest.mock('~/flash');

function createComponent({ props = {}, mountFn = shallowMount } = {}) {
  store = createStore();
  return mountFn(TasksByTypeFilters, {
    localVue,
    store: {
      ...store,
      getters: {
        ...getters,
        currentGroupPath: 'fake',
      },
    },
    propsData: {
      selectedLabelIds,
      labels: groupLabels,
      subjectFilter: TASKS_BY_TYPE_SUBJECT_ISSUE,
      hasData: true,
      ...props,
    },
    stubs: {
      LabelsSelector,
    },
  });
}

describe('TasksByTypeFilters', () => {
  let wrapper = null;
  let mock = null;
  const selectedFilterText = (count = 1) => `Showing Issues and ${count} labels`;

  beforeEach(() => {
    mock = mockGroupLabelsRequest();
    wrapper = createComponent({});

    return waitForPromises();
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  describe('with data', () => {
    beforeEach(() => {
      mock = mockGroupLabelsRequest();
      wrapper = createComponent({});

      return waitForPromises();
    });

    it('renders the selectedFiltersText', () => {
      expect(wrapper.text()).toContain(selectedFilterText());
    });
  });

  describe('with no data', () => {
    beforeEach(() => {
      mock = mockGroupLabelsRequest();
      wrapper = createComponent({ props: { hasData: false } });

      return waitForPromises();
    });
    it('renders the selectedFiltersText', () => {
      expect(wrapper.text()).not.toContain(selectedFilterText());
    });
  });

  describe('labels', () => {
    beforeEach(() => {
      mock = mockGroupLabelsRequest();
      wrapper = createComponent();

      return waitForPromises();
    });

    it('emits the `updateFilter` event when a label is selected', () => {
      expect(wrapper.emitted('updateFilter')).toBeUndefined();

      wrapper.find(LabelsSelector).vm.$emit('selectLabel', groupLabels[0].id);

      expect(wrapper.emitted('updateFilter')).toBeDefined();
      expect(wrapper.emitted('updateFilter')[0]).toEqual([
        { filter: TASKS_BY_TYPE_FILTERS.LABEL, value: groupLabels[0].id },
      ]);
    });

    describe('with the warningMessageThreshold label threshold reached', () => {
      beforeEach(() => {
        mock = mockGroupLabelsRequest();
        wrapper = createComponent({
          props: {
            maxLabels: 5,
            selectedLabelIds: [groupLabels[0].id, groupLabels[1].id],
            warningMessageThreshold: 2,
          },
        });

        return waitForPromises().then(() => selectLabelAtIndex(wrapper, 2));
      });

      it('should indicate how many labels are selected', () => {
        expect(wrapper.text()).toContain('2 selected (5 max)');
      });

      it('renders the selectedFiltersText', () => {
        expect(wrapper.text()).toContain(selectedFilterText(2));
      });
    });

    describe('with maximum labels selected', () => {
      beforeEach(() => {
        mock = mockGroupLabelsRequest();

        wrapper = createComponent({
          props: {
            maxLabels: 2,
            selectedLabelIds: [groupLabels[0].id, groupLabels[1].id],
            warningMessageThreshold: 1,
          },
        });

        return waitForPromises().then(() => {
          wrapper.find(LabelsSelector).vm.$emit('selectLabel', groupLabels[2].id);
        });
      });

      it('should indicate how many labels are selected', () => {
        expect(wrapper.text()).toContain('2 selected (2 max)');
      });

      it('should not allow selecting another label', () => {
        expect(wrapper.emitted('updateFilter')).toBeUndefined();
      });

      it('should display a message', () => {
        expect(createFlash).toHaveBeenCalledWith(
          'Only 2 labels can be selected at this time',
          'notice',
        );
      });
    });
  });

  describe('subject', () => {
    it('has the issue subject set by default', () => {
      expect(findSelectedSubjectFilters(wrapper)).toBe(TASKS_BY_TYPE_SUBJECT_ISSUE);
    });

    it('emits the `updateFilter` event when a subject filter is clicked', () => {
      wrapper = createComponent({ mountFn: mount });
      expect(wrapper.emitted('updateFilter')).toBeUndefined();

      findSubjectFilters(wrapper)
        .findAll('label:not(.active)')
        .at(0)
        .trigger('click');

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.emitted('updateFilter')).toBeDefined();
        expect(wrapper.emitted('updateFilter')[0]).toEqual([
          {
            filter: TASKS_BY_TYPE_FILTERS.SUBJECT,
            value: TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST,
          },
        ]);
      });
    });
  });
});
