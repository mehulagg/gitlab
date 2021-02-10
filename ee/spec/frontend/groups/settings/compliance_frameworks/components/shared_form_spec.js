import { GlForm, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';

import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
import ColorPicker from '~/vue_shared/components/color_picker/color_picker.vue';
import PipelineConfigurationField from 'ee/groups/settings/compliance_frameworks/components/fields/pipeline_configuration.vue';
import { GlFormGroup, GlFormInput } from '../stubs';

import { frameworkFoundResponse, suggestedLabelColors } from '../mock_data';

describe('SharedForm', () => {
  let wrapper;
  const defaultPropsData = { groupEditPath: 'group-1', pipelineConfigurationFullPathEnabled: true };

  const findForm = () => wrapper.findComponent(GlForm);
  const findNameGroup = () => wrapper.find('[data-testid="name-input-group"]');
  const findNameInput = () => wrapper.find('[data-testid="name-input"]');
  const findDescriptionGroup = () => wrapper.find('[data-testid="description-input-group"]');
  const findDescriptionInput = () => wrapper.find('[data-testid="description-input"]');
  const findPipelineConfigurationField = () => wrapper.findComponent(PipelineConfigurationField);
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
        GlFormInput,
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
      expect(findPipelineConfigurationField()).toExist();
      expect(findColorPicker()).toExist();
      expect(findSubmitBtn()).toExist();
      expect(findCancelBtn()).toExist();
    });

    it('shows the name input description', () => {
      wrapper = createComponent();

      expect(findNameGroup().text()).toContain('Use :: to create a scoped set (eg. SOX::AWS)');
    });

    it.each`
      enabled
      ${true}
      ${false}
    `(
      'renders the pipeline configuration input correctly when enabled is $enabled',
      ({ enabled }) => {
        wrapper = createComponent({ pipelineConfigurationFullPathEnabled: enabled });

        expect(findPipelineConfigurationField().exists()).toBe(enabled);
      },
    );
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
      name     | description | color     | isValidPipelineConfiguration | disabled
      ${null}  | ${null}     | ${null}   | ${true}                      | ${'true'}
      ${'Foo'} | ${null}     | ${null}   | ${true}                      | ${'true'}
      ${null}  | ${'Bar'}    | ${null}   | ${true}                      | ${'true'}
      ${null}  | ${null}     | ${'#000'} | ${true}                      | ${'true'}
      ${null}  | ${null}     | ${null}   | ${false}                     | ${'true'}
      ${'Foo'} | ${''}       | ${''}     | ${false}                     | ${'true'}
      ${'Foo'} | ${'Bar'}    | ${'#000'} | ${true}                      | ${undefined}
    `(
      'should set the submit buttons disabled attribute to $disabled when name: $name, description: $description, color: $color, pipelineConfigurationFullPath: $pipelineConfigurationFullPath',
      async ({ name, description, color, isValidPipelineConfiguration, disabled }) => {
        wrapper = createComponent({ name, description, color });

        await findPipelineConfigurationField().vm.$emit('state', isValidPipelineConfiguration);
        await waitForPromises();

        expect(findSubmitBtn().attributes('disabled')).toBe(disabled);
      },
    );
  });

  describe('Updating data', () => {
    it('updates the initial form data when the props are updated', async () => {
      const { name, description, pipelineConfigurationFullPath, color } = frameworkFoundResponse;
      wrapper = createComponent();

      expect(findNameInput().props('value')).toBe(null);
      expect(findDescriptionInput().props('value')).toBe(null);
      expect(findPipelineConfigurationField().props('pipelineConfigurationFullPath')).toBe(null);
      expect(findColorPicker().props('value')).toBe(null);

      await wrapper.setProps({ name, description, pipelineConfigurationFullPath, color });

      expect(findNameInput().props('value')).toBe(name);
      expect(findDescriptionInput().props('value')).toBe(description);
      expect(findPipelineConfigurationField().props('pipelineConfigurationFullPath')).toBe(
        pipelineConfigurationFullPath,
      );
      expect(findColorPicker().props('value')).toBe(color);
    });
  });

  describe('On form submission', () => {
    it('emits a submit event', async () => {
      const { name, description, pipelineConfigurationFullPath, color } = frameworkFoundResponse;
      wrapper = createComponent({ name, description, pipelineConfigurationFullPath, color });

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')).toHaveLength(1);
    });
  });
});
