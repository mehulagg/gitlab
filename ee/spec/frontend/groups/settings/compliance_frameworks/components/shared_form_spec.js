import { GlForm, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { GlFormGroup } from 'jest/registry/shared/stubs';

import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
import ColorPicker from '~/vue_shared/components/color_picker/color_picker.vue';

import { frameworkFoundResponse, suggestedLabelColors } from '../mock_data';

describe('SharedForm', () => {
  let wrapper;
  const defaultPropsData = { groupEditPath: 'group-1' };

  const findForm = () => wrapper.findComponent(GlForm);
  const findNameGroup = () => wrapper.find('[data-testid="name-input-group"]');
  const findNameInput = () => wrapper.find('[data-testid="name-input"]');
  const findDescriptionGroup = () => wrapper.find('[data-testid="description-input-group"]');
  const findDescriptionInput = () => wrapper.find('[data-testid="description-input"]');
  const findColorPicker = () => wrapper.findComponent(ColorPicker);
  const findSubmitBtn = () => wrapper.find('[data-testid="submit-btn"]');
  const findCancelBtn = () => wrapper.find('[data-testid="cancel-btn"]');

  function createComponent(props = {}) {
    return shallowMount(SharedForm, {
      propsData: {
        ...defaultPropsData,
        ...props,
      },
      stubs: {
        GlFormGroup,
        GlFormInput: {
          name: 'gl-form-input-stub',
          props: ['state'],
          template: `
            <div>
              <slot></slot>
            </div>
          `,
        },
        GlSprintf,
      },
    });
  }

  beforeAll(() => {
    gon.suggested_label_colors = suggestedLabelColors;
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Fields', () => {
    it('shows the correct input and button fields', () => {
      wrapper = createComponent();

      expect(findNameInput()).toExist();
      expect(findDescriptionInput()).toExist();
      expect(findColorPicker()).toExist();
      expect(findSubmitBtn()).toExist();
      expect(findCancelBtn()).toExist();
    });

    it('shows the name input description', () => {
      wrapper = createComponent();

      expect(findNameGroup().text()).toContain('Use :: to create a scoped set (eg. SOX::AWS)');
    });
  });

  describe('Validation', () => {
    it.each`
      name        | validity
      ${null}     | ${null}
      ${''}       | ${false}
      ${'foobar'} | ${true}
    `('sets the correct state to the name input and group', ({ name, validity }) => {
      wrapper = createComponent({ name });

      expect(findNameGroup().props('state')).toBe(validity);
      expect(findNameInput().props('state')).toBe(validity);
    });

    it.each`
      description | validity
      ${null}     | ${null}
      ${''}       | ${false}
      ${'foobar'} | ${true}
    `('sets the correct state to the description input and group', ({ description, validity }) => {
      wrapper = createComponent({ description });

      expect(findDescriptionGroup().props('state')).toBe(validity);
      expect(findDescriptionInput().props('state')).toBe(validity);
    });

    it.each`
      color        | validity
      ${null}      | ${null}
      ${''}        | ${null}
      ${'foobar'}  | ${false}
      ${'#00'}     | ${false}
      ${'#000'}    | ${true}
      ${'#000000'} | ${true}
    `('sets the correct state to the color picker', ({ color, validity }) => {
      wrapper = createComponent({ color });

      expect(findColorPicker().props('state')).toBe(validity);
    });

    it.each`
      name     | description | color     | disabled
      ${null}  | ${null}     | ${null}   | ${'true'}
      ${''}    | ${null}     | ${null}   | ${'true'}
      ${null}  | ${''}       | ${null}   | ${'true'}
      ${null}  | ${null}     | ${''}     | ${'true'}
      ${'Foo'} | ${null}     | ${''}     | ${'true'}
      ${'Foo'} | ${'Bar'}    | ${'#000'} | ${undefined}
    `(
      'should set the submit buttons disabled attribute to $disabled',
      ({ name, description, color, disabled }) => {
        wrapper = createComponent({ name, description, color });

        expect(findSubmitBtn().attributes('disabled')).toBe(disabled);
      },
    );
  });

  describe('Updating data', () => {
    it('updates the initial form data when the props are updated', async () => {
      const { name, description, color } = frameworkFoundResponse;
      wrapper = createComponent();

      expect(findNameInput().attributes('value')).toBe(undefined);
      expect(findDescriptionInput().attributes('value')).toBe(undefined);
      expect(findColorPicker().attributes('value')).toBe(undefined);

      await wrapper.setProps({ name, description, color });

      expect(findNameInput().attributes('value')).toBe(name);
      expect(findDescriptionInput().attributes('value')).toBe(description);
      expect(findColorPicker().attributes('value')).toBe(color);
    });
  });

  describe('On form submission', () => {
    it('emits a submit event', async () => {
      const { name, description, color } = frameworkFoundResponse;
      wrapper = createComponent({ name, description, color });

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')).toHaveLength(1);
      expect(wrapper.emitted('submit')[0]).toEqual([{ name, description, color }]);
    });
  });
});
