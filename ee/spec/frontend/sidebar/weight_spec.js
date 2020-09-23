import Vue from 'vue';
import weight from 'ee/sidebar/components/weight/weight.vue';
import mountComponent from 'helpers/vue_mount_component_helper';
import { mockTracking, unmockTracking, triggerEvent } from 'helpers/tracking_helper';
import eventHub from '~/sidebar/event_hub';
import { ENTER_KEY_CODE } from '~/lib/utils/keycodes';

const DEFAULT_PROPS = {
  weightNoneValue: 'None',
};

describe('Weight', () => {
  let vm;
  let Weight;

  beforeEach(() => {
    Weight = Vue.extend(weight);
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('shows loading spinner when fetching', () => {
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      fetching: true,
    });

    expect(vm.$el.querySelector('.js-weight-collapsed-loading-icon')).not.toBeNull();
    expect(vm.$el.querySelector('.js-weight-loading-icon')).not.toBeNull();
  });

  it('shows loading spinner when loading', () => {
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      fetching: false,
      loading: true,
    });

    // We show the value in the collapsed view instead of the loading icon
    expect(vm.$el.querySelector('.js-weight-collapsed-loading-icon')).toBeNull();
    expect(vm.$el.querySelector('.js-weight-loading-icon')).not.toBeNull();
  });

  it('shows weight value', () => {
    const WEIGHT = 3;
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      fetching: false,
      weight: WEIGHT,
    });

    expect(vm.$el.querySelector('.js-weight-collapsed-weight-label').textContent.trim()).toBe(
      `${WEIGHT}`,
    );

    expect(vm.$el.querySelector('.js-weight-weight-label-value').textContent.trim()).toBe(
      `${WEIGHT}`,
    );
  });

  it('shows weight no-value', () => {
    const WEIGHT = null;
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      fetching: false,
      weight: WEIGHT,
    });

    expect(vm.$el.querySelector('.js-weight-collapsed-weight-label').textContent.trim()).toBe(
      'None',
    );

    expect(vm.$el.querySelector('.js-weight-weight-label .no-value').textContent.trim()).toBe(
      'None',
    );
  });

  it('adds `collapse-after-update` class when clicking the collapsed block', () => {
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
    });

    vm.$el.querySelector('.js-weight-collapsed-block').click();

    return vm.$nextTick().then(() => {
      expect(vm.$el.classList.contains('collapse-after-update')).toBe(true);
    });
  });

  it('shows dropdown on "Edit" link click', () => {
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      editable: true,
    });

    expect(vm.shouldShowEditField).toBe(false);

    vm.$el.querySelector('.js-weight-edit-link').click();

    return vm.$nextTick().then(() => {
      expect(vm.shouldShowEditField).toBe(true);
    });
  });

  it('emits event on input submission', () => {
    const ID = 123;
    const expectedWeightValue = '3';
    jest.spyOn(eventHub, '$emit').mockImplementation(() => {});
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      editable: true,
      id: ID,
    });

    vm.$el.querySelector('.js-weight-edit-link').click();

    return vm.$nextTick(() => {
      const event = new CustomEvent('keydown');
      event.keyCode = ENTER_KEY_CODE;

      vm.$refs.editableField.click();
      vm.$refs.editableField.value = expectedWeightValue;
      vm.$refs.editableField.dispatchEvent(event);

      expect(vm.hasValidInput).toBe(true);
      expect(eventHub.$emit).toHaveBeenCalledWith('updateWeight', expectedWeightValue, ID);
    });
  });

  it('emits event on remove weight link click', () => {
    const ID = 123;
    jest.spyOn(eventHub, '$emit').mockImplementation(() => {});
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      editable: true,
      weight: 3,
      id: ID,
    });

    vm.$el.querySelector('.js-weight-remove-link').click();

    return vm.$nextTick(() => {
      expect(vm.hasValidInput).toBe(true);
      expect(eventHub.$emit).toHaveBeenCalledWith('updateWeight', '', ID);
    });
  });

  it('triggers error on invalid negative integer value', () => {
    vm = mountComponent(Weight, {
      ...DEFAULT_PROPS,
      editable: true,
    });

    vm.$el.querySelector('.js-weight-edit-link').click();

    return vm.$nextTick(() => {
      const event = new CustomEvent('keydown');
      event.keyCode = ENTER_KEY_CODE;

      vm.$refs.editableField.click();
      vm.$refs.editableField.value = -9001;
      vm.$refs.editableField.dispatchEvent(event);

      expect(vm.hasValidInput).toBe(false);
    });
  });

  describe('tracking', () => {
    let trackingSpy;

    beforeEach(() => {
      vm = mountComponent(Weight, {
        ...DEFAULT_PROPS,
        editable: true,
      });
      trackingSpy = mockTracking('_category_', vm.$el, (obj, what) =>
        jest.spyOn(obj, what).mockImplementation(() => {}),
      );
    });

    afterEach(() => {
      unmockTracking();
    });

    it('calls trackEvent when "Edit" is clicked', () => {
      triggerEvent(vm.$el.querySelector('.js-weight-edit-link'));

      return vm.$nextTick().then(() => {
        expect(trackingSpy).toHaveBeenCalled();
      });
    });
  });
});
