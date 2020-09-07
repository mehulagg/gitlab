import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlButton, GlModal, GlNewDropdown as GlDropdown, GlFormGroup } from '@gitlab/ui';
import ValueStreamSelect from 'ee/analytics/cycle_analytics/components/value_stream_select.vue';
import { valueStreams } from '../mock_data';
import { findDropdownItemText } from '../helpers';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ValueStreamSelect', () => {
  let wrapper = null;

  const createValueStreamMock = jest.fn(() => Promise.resolve());
  const mockEvent = { preventDefault: jest.fn() };
  const mockToastShow = jest.fn();
  const streamName = 'Cool stream';

  const fakeStore = ({ initialState = {} }) =>
    new Vuex.Store({
      state: {
        isLoading: false,
        createValueStreamErrors: {},
        valueStreams: [],
        selectedValueStream: {},
        ...initialState,
      },
      actions: {
        createValueStream: createValueStreamMock,
      },
    });

  const createComponent = ({ data = {}, initialState = {} } = {}) =>
    shallowMount(ValueStreamSelect, {
      localVue,
      store: fakeStore({ initialState }),
      data() {
        return {
          ...data,
        };
      },
      mocks: {
        $toast: {
          show: mockToastShow,
        },
      },
    });

  const findModal = () => wrapper.find(GlModal);
  const submitButtonDisabledState = () => findModal().props('actionPrimary').attributes[1].disabled;
  const submitForm = () => findModal().vm.$emit('primary', mockEvent);
  const findSelectValueStreamDropdown = () => wrapper.find(GlDropdown);
  const findSelectValueStreamDropdownOptions = _wrapper => findDropdownItemText(_wrapper);
  const findCreateValueStreamButton = () => wrapper.find(GlButton);
  const findFormGroup = () => wrapper.find(GlFormGroup);

  beforeEach(() => {
    wrapper = createComponent({
      initialState: {
        valueStreams,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with value streams available', () => {
    it('does not display the create value stream button', () => {
      expect(findCreateValueStreamButton().exists()).toBe(false);
    });

    it('displays the select value stream dropdown', () => {
      expect(findSelectValueStreamDropdown().exists()).toBe(true);
    });

    it('renders each value stream including a create button', () => {
      const opts = findSelectValueStreamDropdownOptions(wrapper);
      [...valueStreams.map(v => v.name), 'Create new Value Stream'].forEach(vs => {
        expect(opts).toContain(vs);
      });
    });
  });

  describe('Only the default value stream available', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialState: {
          valueStreams: [{ id: 'default', name: 'default' }],
        },
      });
    });

    it('does not display the create value stream button', () => {
      expect(findCreateValueStreamButton().exists()).toBe(false);
    });

    it('displays the select value stream dropdown', () => {
      expect(findSelectValueStreamDropdown().exists()).toBe(true);
    });
  });

  describe('No value streams available', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialState: {
          valueStreams: [],
        },
      });
    });

    it('displays the create value stream button', () => {
      expect(findCreateValueStreamButton().exists()).toBe(true);
    });

    it('does not display the select value stream dropdown', () => {
      expect(findSelectValueStreamDropdown().exists()).toBe(false);
    });
  });

  describe('Create value stream form', () => {
    it('submit button is disabled', () => {
      expect(submitButtonDisabledState()).toBe(true);
    });

    describe('form errors', () => {
      const fieldErrors = ['already exists', 'is required'];

      beforeEach(() => {
        wrapper = createComponent({
          data: { name: streamName },
          initialState: {
            createValueStreamErrors: {
              name: fieldErrors,
            },
          },
        });
      });

      it('renders the error', () => {
        expect(findFormGroup().attributes('invalid-feedback')).toEqual(fieldErrors.join('\n'));
      });

      it('submit button is disabled', () => {
        expect(submitButtonDisabledState()).toBe(true);
      });
    });

    describe('with valid fields', () => {
      beforeEach(() => {
        wrapper = createComponent({ data: { name: streamName } });
      });

      it('submit button is enabled', () => {
        expect(submitButtonDisabledState()).toBe(false);
      });

      describe('form submitted successfully', () => {
        beforeEach(() => {
          submitForm();
        });

        it('calls the "createValueStream" event when submitted', () => {
          expect(createValueStreamMock).toHaveBeenCalledWith(expect.any(Object), {
            name: streamName,
          });
        });

        it('clears the name field', () => {
          expect(wrapper.vm.name).toEqual('');
        });

        it('displays a toast message', () => {
          expect(mockToastShow).toHaveBeenCalledWith(`'${streamName}' Value Stream created`, {
            position: 'top-center',
          });
        });
      });

      describe('form submission fails', () => {
        const createValueStreamMockFail = jest.fn(() => Promise.reject());

        beforeEach(() => {
          wrapper = createComponent({
            data: { name: streamName },
            actions: {
              createValueStream: () => createValueStreamMockFail,
            },
          });
        });

        it('does not clear the name field', () => {
          expect(wrapper.vm.name).toEqual(streamName);
        });

        it('does not display a toast message', () => {
          expect(mockToastShow).not.toHaveBeenCalled();
        });
      });
    });
  });
});
