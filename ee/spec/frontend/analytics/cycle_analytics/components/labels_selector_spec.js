import { mount, shallowMount } from '@vue/test-utils';
import LabelsSelector from 'ee/analytics/cycle_analytics/components/labels_selector.vue';
import { groupLabels } from '../mock_data';

const selectedLabel = groupLabels[groupLabels.length - 1];

describe('Cycle Analytics LabelsSelector', () => {
  function createComponent({ props = {}, shallow = true } = {}) {
    const func = shallow ? shallowMount : mount;
    return func(LabelsSelector, {
      propsData: {
        labels: groupLabels,
        selectedLabelId: props.selectedLabelId || null,
      },
      sync: false,
    });
  }

  let wrapper = null;
  const labelNames = groupLabels.map(({ name }) => name);

  describe('with no item selected', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it.each(labelNames)('generate a label item for the label %s', name => {
      expect(wrapper.text()).toContain(name);
    });

    it('will render with the default option selected', () => {
      const activeItem = wrapper.find('[active="true"]');

      expect(activeItem.exists()).toBe(true);
      expect(activeItem.text()).toEqual('Select a label');
    });

    describe('when a dropdown item is clicked', () => {
      beforeEach(() => {
        wrapper = createComponent({ shallow: false });
      });

      it('will emit the "selectLabel" event', () => {
        expect(wrapper.emitted('selectLabel')).toBeUndefined();

        const elem = wrapper.findAll('.dropdown-item').at(2);
        elem.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('selectLabel').length > 0).toBe(true);
          expect(wrapper.emitted('selectLabel')[0]).toContain(groupLabels[1].id);
        });
      });

      it('will emit the "clearLabel" event if it is the default item', () => {
        expect(wrapper.emitted('clearLabel')).toBeUndefined();

        const elem = wrapper.findAll('.dropdown-item').at(0);
        elem.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('clearLabel').length > 0).toBe(true);
        });
      });
    });
  });

  describe('with selectedLabelId set', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { selectedLabelId: selectedLabel.id } });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('will set the active class', () => {
      const activeItem = wrapper.find('[active="true"]');

      expect(activeItem.exists()).toBe(true);
      expect(activeItem.text()).toEqual(selectedLabel.name);
    });
  });
});
