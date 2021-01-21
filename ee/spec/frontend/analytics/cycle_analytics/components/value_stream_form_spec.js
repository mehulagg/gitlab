import { GlModal } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import ValueStreamForm from 'ee/analytics/cycle_analytics/components/value_stream_form.vue';
import { customStageEvents as formEvents } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ValueStreamForm', () => {
  let wrapper = null;

  const createValueStreamMock = jest.fn(() => Promise.resolve());
  const mockEvent = { preventDefault: jest.fn() };
  const mockToastShow = jest.fn();
  const streamName = 'Cool stream';
  const createValueStreamErrors = { name: ['Name field required'] };

  const fakeStore = ({ initialState = {} }) =>
    new Vuex.Store({
      state: {
        isCreatingValueStream: false,
        createValueStreamErrors: {},
        ...initialState,
      },
      actions: {
        createValueStream: createValueStreamMock,
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

  const createComponent = ({ props = {}, data = {}, initialState = {} } = {}) =>
    shallowMount(ValueStreamForm, {
      localVue,
      store: fakeStore({ initialState }),
      data() {
        return {
          ...data,
        };
      },
      propsData: {
        ...props,
      },
      mocks: {
        $toast: {
          show: mockToastShow,
        },
      },
    });

  const findModal = () => wrapper.find(GlModal);
  const createSubmitButtonDisabledState = () =>
    findModal().props('actionPrimary').attributes[1].disabled;
  const submitModal = () => findModal().vm.$emit('primary', mockEvent);
  const findExtendedFormFields = () => wrapper.find('[data-testid="extended-form-fields"]');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('submit button is disabled', () => {
      expect(createSubmitButtonDisabledState()).toBe(true);
    });

    it('does not include extended fields', () => {
      expect(findExtendedFormFields().exists()).toBe(false);
    });
  });

  describe('with hasExtendedFormFields=true', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { hasExtendedFormFields: true } });
    });

    it('has the extended fields', () => {
      expect(findExtendedFormFields().exists()).toBe(true);
    });
  });

  describe('form errors', () => {
    beforeEach(() => {
      wrapper = createComponent({
        data: { name: streamName },
        initialState: {
          createValueStreamErrors,
        },
      });
    });

    it('submit button is disabled', () => {
      expect(createSubmitButtonDisabledState()).toBe(true);
    });
  });

  describe('with valid fields', () => {
    beforeEach(() => {
      wrapper = createComponent({ data: { name: streamName } });
    });

    it('submit button is enabled', () => {
      expect(createSubmitButtonDisabledState()).toBe(false);
    });

    describe('form submitted successfully', () => {
      beforeEach(() => {
        submitModal();
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
          initialState: {
            createValueStreamErrors,
          },
        });

        submitModal();
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
