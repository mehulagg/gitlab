import { GlAlert, GlLoadingIcon, GlForm, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { GlFormGroup } from 'jest/registry/shared/stubs';

import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
import ColorPicker from '~/vue_shared/components/color_picker/color_picker.vue';

import { frameworkFoundResponse } from '../mock_data';

describe('Form', () => {
  let wrapper;
  const defaultPropsData = { groupEditPath: 'group-1' };

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
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
        GlLoadingIcon,
        GlFormGroup,
        GlSprintf,
      },
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Loading', () => {
    it.each`
      loading
      ${true}
      ${false}
    `('renders the app correctly', ({ loading }) => {
      wrapper = createComponent({ loading });

      expect(findLoadingIcon().exists()).toBe(loading);
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('Rendering the form', () => {
    it.each`
      renderForm
      ${true}
      ${false}
    `('renders the app correctly when the renderForm prop is passed', ({ renderForm }) => {
      wrapper = createComponent({ renderForm });

      expect(findLoadingIcon().exists()).toBe(false);
      expect(findAlert().exists()).toBe(false);
      expect(findForm().exists()).toBe(renderForm);
    });
  });

  describe('Error alert', () => {
    it('shows the alert when an error are passed in', () => {
      wrapper = createComponent({ error: 'Bad things happened' });

      expect(findAlert().text()).toBe('Bad things happened');
    });
  });

  describe('Fields', () => {
    it('shows the correct input and button fields', () => {
      wrapper = createComponent();

      expect(findLoadingIcon().exists()).toBe(false);
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
    it('throws an error if the provided compliance framework is invalid', () => {
      expect(SharedForm.props.complianceFramework.validator({ foo: 'bar' })).toBe(false);
    });

    it.each`
      name        | validity
      ${null}     | ${null}
      ${''}       | ${false}
      ${'foobar'} | ${true}
    `('sends the correct state to the name input group', async ({ name, validity }) => {
      wrapper = createComponent();

      await findNameInput().vm.$emit('input', name);
      expect(findNameGroup().props('state')).toBe(validity);
    });

    it.each`
      description | validity
      ${null}     | ${null}
      ${''}       | ${false}
      ${'foobar'} | ${true}
    `(
      'sends the correct state to the description input group',
      async ({ description, validity }) => {
        wrapper = createComponent();

        await findDescriptionInput().vm.$emit('input', description);
        expect(findDescriptionGroup().props('state')).toBe(validity);
      },
    );

    it.each`
      color        | validity
      ${null}      | ${null}
      ${''}        | ${null}
      ${'foobar'}  | ${false}
      ${'#00'}     | ${false}
      ${'#000'}    | ${true}
      ${'#000000'} | ${true}
    `('sends the correct state to the color picker', async ({ color, validity }) => {
      wrapper = createComponent();
      const colorPicker = findColorPicker();

      await colorPicker.vm.$emit('input', color);
      expect(colorPicker.props('state')).toBe(validity);
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
      async ({ name, description, color, disabled }) => {
        wrapper = createComponent();

        await findNameInput().vm.$emit('input', name);
        await findDescriptionInput().vm.$emit('input', description);
        await findColorPicker().vm.$emit('input', color);

        expect(findSubmitBtn().attributes('disabled')).toBe(disabled);
      },
    );
  });

  describe('Updating data', () => {
    it('updates the initial form data when the compliance framework prop is updated', async () => {
      wrapper = createComponent();

      expect(findNameInput().attributes('value')).toBe(undefined);
      expect(findDescriptionInput().attributes('value')).toBe(undefined);
      expect(findColorPicker().attributes('value')).toBe(undefined);

      await wrapper.setProps({ complianceFramework: frameworkFoundResponse });

      expect(findNameInput().attributes('value')).toBe(frameworkFoundResponse.name);
      expect(findDescriptionInput().attributes('value')).toBe(frameworkFoundResponse.description);
      expect(findColorPicker().attributes('value')).toBe(frameworkFoundResponse.color);
    });
  });

  describe('On form submission', () => {
    it('emits the entered form data', async () => {
      wrapper = createComponent();

      await findNameInput().vm.$emit('input', 'Foo');
      await findDescriptionInput().vm.$emit('input', 'Bar');
      await findColorPicker().vm.$emit('input', '#000');

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')).toHaveLength(1);
      expect(wrapper.emitted('submit')[0]).toEqual([
        { name: 'Foo', description: 'Bar', color: '#000' },
      ]);
    });

    it('does not emit the initial form data if editing has taken place', async () => {
      wrapper = createComponent({ complianceFramework: frameworkFoundResponse });

      await findNameInput().vm.$emit('input', 'Foo');
      await findDescriptionInput().vm.$emit('input', 'Bar');
      await findColorPicker().vm.$emit('input', '#000');

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')).toHaveLength(1);
      expect(wrapper.emitted('submit')[0]).toEqual([
        { name: 'Foo', description: 'Bar', color: '#000' },
      ]);
    });
  });
});
