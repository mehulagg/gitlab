import { GlDropdownSectionHeader } from '@gitlab/ui';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Vuex from 'vuex';
import LabelsSelector from 'ee/analytics/cycle_analytics/components/labels_selector.vue';
import createStore from 'ee/analytics/cycle_analytics/store';
import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import { groupLabels } from '../mock_data';

jest.mock('~/flash');

const selectedLabel = groupLabels[groupLabels.length - 1];
const findActiveItem = (wrapper) =>
  wrapper
    .findAll('gl-dropdown-item-stub')
    .filter((d) => d.attributes('active'))
    .at(0);

const mockGroupLabelsRequest = (status = 200) =>
  new MockAdapter(axios).onGet().reply(status, groupLabels);

describe('Value Stream Analytics LabelsSelector', () => {
  let store = null;
  const localVue = createLocalVue();
  localVue.use(Vuex);

  function createComponent({ props = { selectedLabelId: [] }, shallow = true } = {}) {
    store = createStore();
    const func = shallow ? shallowMount : mount;
    return func(LabelsSelector, {
      localVue,
      store: {
        ...store,
        getters: {
          ...getters,
          currentGroupPath: 'fake',
        },
      },
      propsData: {
        ...props,
      },
    });
  }

  let wrapper = null;
  let mock = null;
  const labelNames = groupLabels.map(({ name }) => name);

  describe('with no item selected', () => {
    beforeEach(() => {
      mock = mockGroupLabelsRequest();
      wrapper = createComponent({});

      return waitForPromises();
    });

    afterEach(() => {
      mock.restore();
      wrapper.destroy();
      wrapper = null;
    });

    it('will render the label selector', () => {
      expect(wrapper.html()).toMatchSnapshot();
    });

    it.each(labelNames)('generate a label item for the label %s', (name) => {
      expect(wrapper.text()).toContain(name);
    });

    it('will render with the default option selected', () => {
      const sectionHeader = wrapper.findComponent(GlDropdownSectionHeader);

      expect(sectionHeader.exists()).toBe(true);
      expect(sectionHeader.text()).toEqual('Select a label');
    });

    describe('with a failed request', () => {
      beforeEach(() => {
        mock = mockGroupLabelsRequest(404);
        wrapper = createComponent({});

        return waitForPromises();
      });

      it('should flash an error message', () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'There was an error fetching label data for the selected group',
        });
      });
    });

    describe('when a dropdown item is clicked', () => {
      beforeEach(() => {
        mock = mockGroupLabelsRequest();
        wrapper = createComponent({ shallow: false });
        return waitForPromises();
      });

      it('will emit the "select-label" event', () => {
        expect(wrapper.emitted('select-label')).toBeUndefined();

        const elem = wrapper.findAll('.dropdown-item').at(1);
        elem.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('select-label').length > 0).toBe(true);
          expect(wrapper.emitted('select-label')[0]).toContain(groupLabels[1].id);
        });
      });
    });
  });

  describe('with selectedLabelId set', () => {
    beforeEach(() => {
      mock = mockGroupLabelsRequest();
      wrapper = createComponent({ props: { selectedLabelId: [selectedLabel.id] } });
      return waitForPromises();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('will render the label selector', () => {
      expect(wrapper.html()).toMatchSnapshot();
    });

    it('will set the active label', () => {
      const activeItem = findActiveItem(wrapper);

      expect(activeItem.exists()).toBe(true);
      expect(activeItem.text()).toEqual(selectedLabel.name);
    });
  });
});
