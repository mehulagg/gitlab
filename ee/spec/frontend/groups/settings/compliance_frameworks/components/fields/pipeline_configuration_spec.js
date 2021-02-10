import { shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';

import PipelineConfigurationField from 'ee/groups/settings/compliance_frameworks/components/fields/pipeline_configuration.vue';
import * as Utils from 'ee/groups/settings/compliance_frameworks/utils';
import { GlFormGroup, GlFormInput } from '../../stubs';

describe('PipelineConfigurationField', () => {
  let wrapper;

  const findGroup = () => wrapper.findComponent(GlFormGroup);
  const findInput = () => wrapper.findComponent(GlFormInput);

  function createComponent(props = {}) {
    return shallowMount(PipelineConfigurationField, {
      propsData: {
        ...props,
      },
      stubs: {
        GlFormGroup,
        GlFormInput,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Field', () => {
    it.each`
      value
      ${null}
      ${''}
      ${'foo.yml@bar/baz'}
    `('shows the input and group with the value $value', ({ value }) => {
      wrapper = createComponent({ pipelineConfigurationFullPath: value });

      expect(findGroup()).toExist();
      expect(findInput().props('value')).toBe(value);
    });
  });

  describe('Validation', () => {
    it.each`
      pipelineConfigurationFullPath | message
      ${'foobar'}                   | ${'Invalid format: it should follow the format [PATH].yml@[GROUP]/[PROJECT]'}
      ${'foo.yml@bar/baz'}          | ${'Could not find this configuration location, please try a different location'}
    `(
      'sets the correct invalid message to the group',
      async ({ pipelineConfigurationFullPath, message }) => {
        jest.spyOn(Utils, 'checkPipelineConfigurationFileExists').mockReturnValue(false);

        wrapper = createComponent();

        await findInput().vm.$emit('input', pipelineConfigurationFullPath);
        await waitForPromises();

        expect(findGroup().attributes('invalid-feedback')).toBe(message);
      },
    );

    it.each`
      pipelineConfigurationFullPath | validity
      ${null}                       | ${null}
      ${''}                         | ${null}
      ${'foobar'}                   | ${false}
      ${'foo.yml@bar/zab'}          | ${false}
      ${'foo.yml@bar/baz'}          | ${true}
    `(
      'sets the correct state for the input and group',
      async ({ pipelineConfigurationFullPath, validity }) => {
        jest
          .spyOn(Utils, 'checkPipelineConfigurationFileExists')
          .mockReturnValue(Boolean(validity));

        wrapper = createComponent();
        const input = findInput();

        await input.vm.$emit('input', pipelineConfigurationFullPath);
        await waitForPromises();

        expect(findGroup().props('state')).toBe(validity);
        expect(input.props('state')).toBe(validity);
      },
    );
  });

  describe('Events', () => {
    it.each`
      value
      ${'foobar'}
      ${'foo.yml@bar/zab'}
    `('emits only the false state event when invalid value $value is used', async ({ value }) => {
      jest.spyOn(Utils, 'checkPipelineConfigurationFileExists').mockReturnValue(false);

      wrapper = createComponent();
      const input = findInput();

      await input.vm.$emit('input', value);
      await waitForPromises();

      expect(wrapper.emitted().state).toStrictEqual([[false]]);
      expect(wrapper.emitted()['update:pipelineConfigurationFullPath']).toBe(undefined);
    });

    it.each`
      value
      ${null}
      ${''}
    `('emits the true state event and the update event when value is $value', async ({ value }) => {
      wrapper = createComponent();
      const input = findInput();

      await input.vm.$emit('input', value);
      await waitForPromises();

      expect(wrapper.emitted().state).toStrictEqual([[false], [true]]);
      expect(wrapper.emitted()['update:pipelineConfigurationFullPath']).toStrictEqual([[null]]);
    });

    it('emits the true state event and the update event when valid', async () => {
      jest.spyOn(Utils, 'checkPipelineConfigurationFileExists').mockReturnValue(true);

      wrapper = createComponent();
      const value = 'foo.yml@bar/baz';
      const input = findInput();

      await input.vm.$emit('input', value);
      await waitForPromises();

      expect(wrapper.emitted().state).toStrictEqual([[false], [true]]);
      expect(wrapper.emitted()['update:pipelineConfigurationFullPath']).toStrictEqual([[value]]);
    });
  });
});
