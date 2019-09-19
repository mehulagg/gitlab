import { mount, createLocalVue } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';

import CreateEpicForm from 'ee/related_items_tree/components/create_epic_form.vue';

const createComponent = (isSubmitting = false) => {
  const localVue = createLocalVue();

  return mount(CreateEpicForm, {
    localVue,
    propsData: {
      isSubmitting,
    },
  });
};

describe('RelatedItemsTree', () => {
  describe('CreateEpicForm', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('computed', () => {
      describe('isSubmitButtonDisabled', () => {
        it('returns true when either `inputValue` prop is empty or `isSubmitting` prop is true', () => {
          expect(wrapper.vm.isSubmitButtonDisabled).toBe(true);
        });

        it('returns false when either `inputValue` prop is non-empty or `isSubmitting` prop is false', done => {
          const wrapperWithInput = createComponent(false);

          wrapperWithInput.setData({
            inputValue: 'foo',
          });

          wrapperWithInput.vm.$nextTick(() => {
            expect(wrapperWithInput.vm.isSubmitButtonDisabled).toBe(false);

            wrapperWithInput.destroy();
            done();
          });
        });
      });

      describe('buttonLabel', () => {
        it('returns string "Creating epic" when `isSubmitting` prop is true', done => {
          const wrapperSubmitting = createComponent(true);

          wrapperSubmitting.vm.$nextTick(() => {
            expect(wrapperSubmitting.vm.buttonLabel).toBe('Creating epic');

            wrapperSubmitting.destroy();
            done();
          });
        });

        it('returns string "Create epic" when `isSubmitting` prop is false', () => {
          expect(wrapper.vm.buttonLabel).toBe('Create epic');
        });
      });
    });

    describe('methods', () => {
      describe('onFormSubmit', () => {
        it('emits `createEpicFormSubmit` event on component with input value as param', () => {
          const value = 'foo';
          wrapper.find('input.form-control').setValue(value);

          wrapper.vm.onFormSubmit();

          expect(wrapper.emitted().createEpicFormSubmit).toBeTruthy();
          expect(wrapper.emitted().createEpicFormSubmit[0]).toEqual([value]);
        });
      });

      describe('onFormCancel', () => {
        it('emits `createEpicFormCancel` event on component', () => {
          wrapper.vm.onFormCancel();

          expect(wrapper.emitted().createEpicFormCancel).toBeTruthy();
        });
      });
    });

    describe('template', () => {
      it('renders input element within form', () => {
        const inputEl = wrapper.find('input.form-control');

        expect(inputEl.attributes('placeholder')).toBe('New epic title');
      });

      it('renders form action buttons', () => {
        const actionButtons = wrapper.findAll(GlButton);

        expect(actionButtons.at(0).text()).toBe('Create epic');
        expect(actionButtons.at(1).text()).toBe('Cancel');
      });
    });
  });
});
