import { GlAlert, GlModal, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import DeleteValueStreamModal from 'ee/analytics/cycle_analytics/components/delete_value_stream_modal.vue';
import { I18N } from 'ee/analytics/cycle_analytics/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import Tracking from '~/tracking';
import { valueStreams } from '../mock_data';

const selectedValueStream = valueStreams[0];
const actionSpies = {
  deleteValueStream: jest.fn(),
};

const defaultInitialState = {
  isDeleting: false,
  deleteValueStreamError: '',
  selectedValueStream,
};

function fakeStore(initialState = {}, actions) {
  return new Vuex.Store({
    state: {
      ...defaultInitialState,
      ...initialState,
    },
    actions,
  });
}

function createComponent({
  propsData = {
    isVisible: true,
  },
  initialState = {},
  actions = actionSpies,
} = {}) {
  console.log('actions', actions);
  return extendedWrapper(
    shallowMount(DeleteValueStreamModal, {
      store: fakeStore(initialState, actions),
      propsData: {
        selectedValueStream,
        ...propsData,
      },
      stubs: { GlSprintf },
    }),
  );
}

describe('Delete Value Stream Modal', () => {
  Vue.use(Vuex);
  let wrapper;

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findModal = () => wrapper.findComponent(GlModal);
  const findPrimaryBtn = () => findModal().props('actionPrimary');

  beforeEach(() => {
    jest.spyOn(Tracking, 'event');
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('will set the modal `visible=true`', () => {
    expect(findModal().props('visible')).toBe(true);
  });

  it('will render the correct title', () => {
    expect(findModal().props('title')).toMatchInterpolatedText(I18N.DELETE_VALUE_STREAM_TITLE);
  });

  it('will not display an alert', () => {
    expect(findAlert().exists()).toBe(false);
  });

  it('will contain the confirmation message', () => {
    expect(wrapper.text()).toMatchInterpolatedText(
      'Are you sure you want to delete the "Value stream 1" Value Stream?',
    );
  });

  it('will render the delete button', () => {
    expect(findPrimaryBtn()).toMatchObject({
      text: I18N.DELETE,
      attributes: [{ variant: 'danger' }, { loading: undefined }],
    });
  });

  it('will emit the `hidden` event when the modal is hidden', () => {
    expect(wrapper.emitted('hidden')).toBeUndefined();
    findModal().vm.$emit('hidden');
    expect(wrapper.emitted('hidden')).toBeDefined();
  });

  describe('when the delete button is clicked', () => {
    beforeEach(async () => {
      wrapper = createComponent();

      findModal().vm.$emit('primary');
      await wrapper.vm.$nextTick();
    });

    it('will call `deleteValueStream', () => {
      expect(actionSpies.deleteValueStream).toHaveBeenCalledWith(
        expect.anything(),
        selectedValueStream.id,
      );
    });

    describe('with a successful request', () => {
      it('will emit `success', () => {
        expect(wrapper.emitted('success')).toBeDefined();
        expect(wrapper.emitted('success')[0]).toEqual(["'Value stream 1' Value Stream deleted"]);
      });

      it('sends tracking information', () => {
        expect(Tracking.event).toHaveBeenCalledWith(undefined, 'delete_value_stream', {
          extra: { name: selectedValueStream.name },
        });
      });
    });

    describe.only('with a failed request', () => {
      beforeEach(async () => {
        // const mockDeleteValueStream = jest.fn(() => );

        wrapper = createComponent({ actions: { deleteValueStream: jest.fn(Promise.reject()) } });

        findModal().vm.$emit('primary');
        await wrapper.vm.$nextTick();
        await waitForPromises();
      });

      it('does not emit `success', () => {
        expect(wrapper.emitted('success')).toBeUndefined();
      });

      it('does not send tracking information', () => {
        expect(Tracking.event).not.toHaveBeenCalled();
      });
    });
  });

  describe('with `isDeletingValueStream=true`', () => {
    beforeEach(() => {
      wrapper = createComponent({ initialState: { isDeletingValueStream: true } });
    });

    it('will set the delete button loading state', () => {
      expect(findPrimaryBtn()).toMatchObject({
        text: I18N.DELETE,
        attributes: [{ variant: 'danger' }, { loading: true }],
      });
    });
  });

  describe('with `isVisible=false`', () => {
    beforeEach(() => {
      wrapper = createComponent({ propsData: { isVisible: false } });
    });

    it('will set the modal `visible=false`', () => {
      expect(findModal().props('visible')).toBe(false);
    });
  });

  describe('with `deleteValueStreamError` set', () => {
    const deleteValueStreamError = 'Houston, we have a problem';
    beforeEach(() => {
      wrapper = createComponent({ initialState: { deleteValueStreamError } });
    });

    it('will render an alert', () => {
      expect(findAlert().exists()).toBe(true);
    });

    it('will render the error message', () => {
      expect(findAlert().text()).toBe(deleteValueStreamError);
    });
  });
});
