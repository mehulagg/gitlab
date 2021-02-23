import { GlModal, GlFormInput } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { PRESET_OPTIONS_BLANK } from 'ee/analytics/cycle_analytics/components/create_value_stream_form/constants';
import CustomStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/custom_stage_fields.vue';
import DefaultStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/default_stage_fields.vue';
import ValueStreamForm from 'ee/analytics/cycle_analytics/components/value_stream_form.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import {
  convertObjectPropsToCamelCase,
  convertObjectPropsToSnakeCase,
} from '~/lib/utils/common_utils';
import { customStageEvents as formEvents, defaultStageConfig, rawCustomStage } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ValueStreamForm', () => {
  let wrapper;

  const createValueStreamMock = jest.fn(() => Promise.resolve());
  const updateValueStreamMock = jest.fn(() => Promise.resolve());
  const mockEvent = { preventDefault: jest.fn() };
  const mockToastShow = jest.fn();
  const streamName = 'Cool stream';
  const initialFormErrors = { name: ['Name field required'] };
  const initialFormStageErrors = {
    stages: [
      {
        name: ['Name field is required'],
        endEventIdentifier: ['Please select a start event first'],
      },
    ],
  };

  const initialData = {
    stages: [convertObjectPropsToCamelCase(rawCustomStage)],
    id: 1337,
    name: 'Editable value stream',
  };

  const initialPreset = PRESET_OPTIONS_BLANK;

  const fakeStore = () =>
    new Vuex.Store({
      state: {
        isCreatingValueStream: false,
      },
      actions: {
        createValueStream: createValueStreamMock,
        updateValueStream: updateValueStreamMock,
      },
      modules: {
        customStages: {
          namespaced: true,
          state: {
            formEvents,
          },
        },
      },
    });

  const createComponent = ({ props = {}, data = {}, stubs = {} } = {}) =>
    extendedWrapper(
      shallowMount(ValueStreamForm, {
        localVue,
        store: fakeStore(),
        data() {
          return {
            ...data,
          };
        },
        propsData: {
          defaultStageConfig,
          ...props,
        },
        mocks: {
          $toast: {
            show: mockToastShow,
          },
        },
        stubs: {
          ...stubs,
        },
      }),
    );

  const findModal = () => wrapper.findComponent(GlModal);
  const clickSubmit = () => findModal().vm.$emit('primary', mockEvent);
  const clickAddStage = () => findModal().vm.$emit('secondary', mockEvent);
  const findExtendedFormFields = () => wrapper.findByTestId('extended-form-fields');
  const findPresetSelector = () => wrapper.findByTestId('vsa-preset-selector');
  const findBtn = (btn) => findModal().props(btn);
  const findSubmitAttribute = (attribute) => findBtn('actionPrimary').attributes[1][attribute];
  const expectFieldError = (testId, error = '') =>
    expect(wrapper.findByTestId(testId).attributes('invalid-feedback')).toBe(error);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default state', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('submit button is enabled', () => {
      expect(findSubmitAttribute('disabled')).toBeUndefined();
    });

    it('does not include extended fields', () => {
      expect(findExtendedFormFields().exists()).toBe(false);
    });

    it('does not include add stage button', () => {
      expect(findBtn('actionSecondary').attributes).toContainEqual({
        class: 'gl-display-none',
      });
    });

    it('does not include the preset selector', () => {
      expect(findPresetSelector().exists()).toBe(false);
    });
  });

  describe('with hasExtendedFormFields=true', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { hasExtendedFormFields: true } });
    });

    it('has the extended fields', () => {
      expect(findExtendedFormFields().exists()).toBe(true);
    });

    it('sets the submit action text to "Create Value Stream"', () => {
      expect(findBtn('actionPrimary').text).toBe('Create Value Stream');
    });

    describe('Preset selector', () => {
      it('has the preset button', () => {
        expect(findPresetSelector().exists()).toBe(true);
      });
    });

    describe('Add stage button', () => {
      it('has the add stage button', () => {
        expect(findBtn('actionSecondary')).toMatchObject({ text: 'Add another stage' });
      });

      it('adds a blank custom stage when clicked', () => {
        expect(wrapper.vm.stages.length).toBe(defaultStageConfig.length);

        clickAddStage();

        expect(wrapper.vm.stages.length).toBe(defaultStageConfig.length + 1);
      });

      it('validates existing fields when clicked', () => {
        expect(wrapper.vm.nameError).toEqual([]);

        clickAddStage();

        expect(wrapper.vm.nameError).toEqual(['Name is required']);
      });
    });

    describe('form errors', () => {
      const commonExtendedData = {
        props: {
          hasExtendedFormFields: true,
          initialFormErrors: initialFormStageErrors,
        },
      };

      it('renders errors for a default stage field', () => {
        wrapper = createComponent({
          ...commonExtendedData,
          stubs: {
            DefaultStageFields,
          },
        });

        expectFieldError('default-stage-name-0', initialFormStageErrors.stages[0].name[0]);
      });

      it('renders errors for a custom stage field', async () => {
        wrapper = createComponent({
          props: {
            ...commonExtendedData.props,
            initialPreset: PRESET_OPTIONS_BLANK,
          },
          stubs: {
            CustomStageFields,
          },
        });

        expectFieldError('custom-stage-name-0', initialFormStageErrors.stages[0].name[0]);
        expectFieldError(
          'custom-stage-end-event-0',
          initialFormStageErrors.stages[0].endEventIdentifier[0],
        );
      });
    });

    describe('isEditing=true', () => {
      const stageCount = initialData.stages.length;
      beforeEach(() => {
        wrapper = createComponent({
          props: {
            initialPreset,
            initialData,
            isEditing: true,
            hasExtendedFormFields: true,
          },
        });
      });

      it('does not have the preset button', () => {
        expect(findPresetSelector().exists()).toBe(false);
      });

      it('sets the submit action text to "Save Value Stream"', () => {
        expect(findBtn('actionPrimary').text).toBe('Save Value Stream');
      });

      describe('Add stage button', () => {
        it('has the add stage button', () => {
          expect(findBtn('actionSecondary')).toMatchObject({ text: 'Add another stage' });
        });

        it('adds a blank custom stage when clicked', () => {
          expect(wrapper.vm.stages.length).toBe(stageCount);

          clickAddStage();

          expect(wrapper.vm.stages.length).toBe(stageCount + 1);
        });

        it('validates existing fields when clicked', () => {
          expect(wrapper.vm.nameError).toEqual([]);

          wrapper.findByTestId('create-value-stream-name').find(GlFormInput).vm.$emit('input', '');

          clickAddStage();

          expect(wrapper.vm.nameError).toEqual(['Name is required']);
        });
      });

      describe('with valid fields', () => {
        beforeEach(() => {
          wrapper = createComponent({
            props: {
              initialPreset,
              initialData,
              isEditing: true,
              hasExtendedFormFields: true,
            },
          });
        });

        describe('form submitted successfully', () => {
          beforeEach(() => {
            clickSubmit();
          });

          it('calls the "updateValueStreamMock" event when submitted', () => {
            expect(updateValueStreamMock).toHaveBeenCalledWith(expect.any(Object), {
              ...initialData,
              stages: initialData.stages.map((stage) =>
                convertObjectPropsToSnakeCase(stage, { deep: true }),
              ),
            });
          });

          it('displays a toast message', () => {
            expect(mockToastShow).toHaveBeenCalledWith(
              `'${initialData.name}' Value Stream edited`,
              {
                position: 'top-center',
              },
            );
          });
        });

        describe('form submission fails', () => {
          beforeEach(() => {
            wrapper = createComponent({
              data: { name: streamName },
              props: {
                initialFormErrors,
              },
            });

            clickSubmit();
          });

          it('does not call the updateValueStreamMock action', () => {
            expect(updateValueStreamMock).not.toHaveBeenCalled();
          });

          it('does not clear the name field', () => {
            expect(wrapper.vm.name).toBe(streamName);
          });

          it('does not display a toast message', () => {
            expect(mockToastShow).not.toHaveBeenCalled();
          });
        });
      });
    });
  });

  describe('form errors', () => {
    beforeEach(() => {
      wrapper = createComponent({
        data: { name: '' },
        props: {
          initialFormErrors,
        },
      });
    });

    it('renders errors for the name field', () => {
      expectFieldError('create-value-stream-name', initialFormErrors.name[0]);
    });
  });

  describe('with valid fields', () => {
    beforeEach(() => {
      wrapper = createComponent({ data: { name: streamName } });
    });

    describe('form submitted successfully', () => {
      beforeEach(() => {
        clickSubmit();
      });

      it('calls the "createValueStream" event when submitted', () => {
        expect(createValueStreamMock).toHaveBeenCalledWith(expect.any(Object), {
          name: streamName,
          stages: [],
        });
      });

      it('clears the name field', () => {
        expect(wrapper.vm.name).toBe('');
      });

      it('displays a toast message', () => {
        expect(mockToastShow).toHaveBeenCalledWith(`'${streamName}' Value Stream created`, {
          position: 'top-center',
        });
      });
    });

    describe('form submission fails', () => {
      beforeEach(() => {
        wrapper = createComponent({
          data: { name: streamName },
          props: {
            initialFormErrors,
          },
        });

        clickSubmit();
      });

      it('calls the createValueStream action', () => {
        expect(createValueStreamMock).toHaveBeenCalled();
      });

      it('does not clear the name field', () => {
        expect(wrapper.vm.name).toBe(streamName);
      });

      it('does not display a toast message', () => {
        expect(mockToastShow).not.toHaveBeenCalled();
      });
    });
  });
});
