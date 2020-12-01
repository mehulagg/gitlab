import { GlButton, GlDropdown, GlFormGroup } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import ValueStreamSelect from 'ee/analytics/cycle_analytics/components/value_stream_select.vue';
import { findDropdownItemText } from '../helpers';
import { valueStreams } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ValueStreamSelect', () => {
  let wrapper = null;

  const createValueStreamMock = jest.fn(() => Promise.resolve());
  const deleteValueStreamMock = jest.fn(() => Promise.resolve());
  const mockEvent = { preventDefault: jest.fn() };
  const mockToastShow = jest.fn();
  const streamName = 'Cool stream';
  const selectedValueStream = valueStreams[0];
  const createValueStreamErrors = { name: ['Name field required'] };
  const deleteValueStreamError = 'Cannot delete default value stream';

  const fakeStore = ({ initialState = {} }) =>
    new Vuex.Store({
      state: {
        isCreatingValueStream: false,
        isDeletingValueStream: false,
        createValueStreamErrors: {},
        deleteValueStreamError: null,
        valueStreams: [],
        selectedValueStream: {},
        ...initialState,
      },
      actions: {
        createValueStream: createValueStreamMock,
        deleteValueStream: deleteValueStreamMock,
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

  const findModal = modal => wrapper.find(`[data-testid="${modal}-value-stream-modal"]`);
  const createSubmitButtonDisabledState = () =>
    findModal('create').props('actionPrimary').attributes[1].disabled;
  const submitModal = modal => findModal(modal).vm.$emit('primary', mockEvent);
  const findSelectValueStreamDropdown = () => wrapper.find(GlDropdown);
  const findSelectValueStreamDropdownOptions = _wrapper => findDropdownItemText(_wrapper);
  const findCreateValueStreamButton = () => wrapper.find(GlButton);
  const findDeleteValueStreamButton = () => wrapper.find('[data-testid="delete-value-stream"]');
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

    describe('with a selected value stream', () => {
      it('renders a delete option for custom value streams', () => {
        wrapper = createComponent({
          initialState: {
            valueStreams,
            selectedValueStream: {
              ...selectedValueStream,
              isCustom: true,
            },
          },
        });

        expect(findDeleteValueStreamButton().exists()).toBe(true);
        expect(findDeleteValueStreamButton().text()).toBe(`Delete ${selectedValueStream.name}`);
      });

      it('does not render a delete option for default value streams', () => {
        wrapper = createComponent({
          initialState: {
            valueStreams,
            selectedValueStream,
          },
        });

        expect(findDeleteValueStreamButton().exists()).toBe(false);
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
      expect(createSubmitButtonDisabledState()).toBe(true);
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

      it('renders the error', () => {
        expect(findFormGroup().attributes('invalid-feedback')).toEqual(
          createValueStreamErrors.name.join('\n'),
        );
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
          submitModal('create');
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
        beforeEach(() => {
          wrapper = createComponent({
            data: { name: streamName },
            initialState: {
              createValueStreamErrors,
            },
          });

          submitModal('create');
        });

        it('calls the createValueStream action', () => {
          expect(createValueStreamMock).toHaveBeenCalled();
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

  describe('Delete value stream modal', () => {
    describe('succeeds', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialState: {
            valueStreams,
            selectedValueStream: {
              ...selectedValueStream,
              isCustom: true,
            },
          },
        });

        submitModal('delete');
      });

      it('calls the "deleteValueStream" event when submitted', () => {
        expect(deleteValueStreamMock).toHaveBeenCalledWith(
          expect.any(Object),
          selectedValueStream.id,
        );
      });

      it('displays a toast message', () => {
        expect(mockToastShow).toHaveBeenCalledWith(
          `'${selectedValueStream.name}' Value Stream deleted`,
          {
            position: 'top-center',
          },
        );
      });
    });

    describe('fails', () => {
      beforeEach(() => {
        wrapper = createComponent({
          data: { name: streamName },
          initialState: { deleteValueStreamError },
        });
      });

      it('does not display a toast message', () => {
        expect(mockToastShow).not.toHaveBeenCalled();
      });
    });
  });
});
