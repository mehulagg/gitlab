import { GlAlert, GlLoadingIcon, GlForm } from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
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

  function createComponent(props = {}, mountFn = mount) {
    return mountFn(SharedForm, {
      propsData: {
        ...defaultPropsData,
        ...props,
      },
      stubs: {
        GlLoadingIcon,
        GlFormGroup,
      },
    });
  }

  beforeEach(() => {
    gon.suggested_label_colors = {
      '#000000': 'Black',
      '#0033CC': 'UA blue',
      '#428BCA': 'Moderate blue',
      '#44AD8E': 'Lime green',
    };
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Loading', () => {
    it.each`
      loading
      ${true}
      ${false}
    `('renders the app correctly', ({ loading }) => {
      wrapper = createComponent({ loading }, shallowMount);

      expect(findLoadingIcon().exists()).toBe(loading);
      expect(findAlert().exists()).toBe(false);
      expect(findForm().exists()).toBe(!loading);
    });
  });

  describe('Error alert', () => {
    it('shows the alert when an error are passed in', () => {
      wrapper = createComponent({ error: 'Bad things happened' }, shallowMount);

      expect(findAlert().text()).toBe('Bad things happened');
    });
  });

  describe('Fields', () => {
    it('shows the correct input and button fields', () => {
      wrapper = createComponent({}, shallowMount);

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
    it.each`
      name        | validity
      ${null}     | ${null}
      ${''}       | ${false}
      ${'foobar'} | ${true}
    `('sends the correct state to the name input group', async ({ name, validity }) => {
      wrapper = createComponent({}, shallowMount);

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
        wrapper = createComponent({}, shallowMount);

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
      wrapper = createComponent({}, shallowMount);
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
        wrapper = createComponent({}, shallowMount);

        await findNameInput().vm.$emit('input', name);
        await findDescriptionInput().vm.$emit('input', description);
        await findColorPicker().vm.$emit('input', color);

        expect(findSubmitBtn().attributes('disabled')).toBe(disabled);
      },
    );
  });

  describe('Updating data', () => {
    it('updates the initial form data when the compliance framework prop is updated', async () => {
      wrapper = createComponent({}, shallowMount);

      expect(wrapper.vm.name).toBe(null);
      expect(wrapper.vm.description).toBe(null);
      expect(wrapper.vm.color).toBe(null);

      await wrapper.setProps({ complianceFramework: frameworkFoundResponse });

      expect(wrapper.vm.name).toBe(frameworkFoundResponse.name);
      expect(wrapper.vm.description).toBe(frameworkFoundResponse.description);
      expect(wrapper.vm.color).toBe(frameworkFoundResponse.color);
    });

    it('updates only unedited form data when the compliance framework prop is updated', async () => {
      wrapper = createComponent({}, shallowMount);

      expect(wrapper.vm.name).toBe(null);
      expect(wrapper.vm.description).toBe(null);
      expect(wrapper.vm.color).toBe(null);

      await findNameInput().vm.$emit('input', 'Foo');
      await wrapper.setProps({ complianceFramework: frameworkFoundResponse });

      expect(wrapper.vm.name).toBe('Foo');
      expect(wrapper.vm.description).toBe(frameworkFoundResponse.description);
      expect(wrapper.vm.color).toBe(frameworkFoundResponse.color);
    });
  });

  describe('On form submission', () => {
    it('emits the entered form data', async () => {
      wrapper = createComponent({}, shallowMount);

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
      wrapper = createComponent({ complianceFramework: frameworkFoundResponse }, shallowMount);

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
