import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlSprintf, GlDropdownItem } from '@gitlab/ui';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Vuex from 'vuex';
import CustomStageForm from 'ee/analytics/cycle_analytics/components/custom_stage_form.vue';
import CustomStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/custom_stage_fields.vue';
import { STAGE_ACTIONS } from 'ee/analytics/cycle_analytics/constants';
import customStagesStore from 'ee/analytics/cycle_analytics/store/modules/custom_stages';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import {
  endpoints,
  groupLabels,
  customStageEvents as events,
  customStageFormErrors,
} from '../mock_data';
import {
  emptyState,
  formInitialData,
  minimumFields,
  MERGE_REQUEST_CREATED,
  MERGE_REQUEST_CLOSED,
  ISSUE_CREATED,
  ISSUE_CLOSED,
} from './create_value_stream_form/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const fakeStore = ({ initialState, initialRootGetters }) =>
  new Vuex.Store({
    getters: {
      currentGroupPath: () => 'fake',
      hiddenStages: () => [],
      ...initialRootGetters,
    },
    modules: {
      customStages: {
        ...customStagesStore,
        state: {
          isLoading: false,
          ...initialState,
        },
      },
    },
  });

describe('CustomStageForm', () => {
  function createComponent({
    initialState = {},
    initialRootGetters = {},
    stubs = {},

    props = {},
  } = {}) {
    return shallowMount(CustomStageForm, {
      localVue,
      store: fakeStore({ initialState, initialRootGetters }),
      propsData: {
        events,
        ...props,
      },
      stubs: {
        GlSprintf,
        CustomStageFields,
        ...stubs,
      },
    });
  }

  let wrapper = null;
  let mock;

  const findEvent = (ev) => wrapper.emitted()[ev];

  const findSubmitButton = () => wrapper.find('[data-testid="save-custom-stage"]');
  const findCancelButton = () => wrapper.find('[data-testid="cancel-custom-stage"]');
  const findRecoverStageDropdown = () =>
    wrapper.find('[data-testid="recover-hidden-stage-dropdown"]');

  const findFieldErrors = (field) => wrapper.vm.errors[field];

  const setFields = async (fields = minimumFields) => {
    Object.entries(fields).forEach(([field, value]) => {
      wrapper.find(CustomStageFields).vm.$emit('input', { field, value });
    });
    await wrapper.vm.$nextTick();
  };

  const setNameField = (value = '') => setFields({ name: value });

  const setStartEvent = (value = MERGE_REQUEST_CREATED) =>
    setFields({ startEventIdentifier: value });
  const setEndEvent = (value = MERGE_REQUEST_CLOSED) => setFields({ endEventIdentifier: value });

  const mockGroupLabelsRequest = () =>
    new MockAdapter(axios).onGet(endpoints.groupLabels).reply(200, groupLabels);

  beforeEach(async () => {
    mock = mockGroupLabelsRequest();
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
  });

  describe('Default state', () => {
    it('will set all fields to null', () => {
      expect(wrapper.vm.fields).toMatchObject(emptyState);
    });

    it('displays the manual ordering helper text', () => {
      expect(wrapper.html()).toContain(
        '<strong>Note:</strong> Once a custom stage has been added you can re-order stages by dragging them into the desired position.',
      );
    });
  });

  describe('Name', () => {
    describe('with a reserved name', () => {
      beforeEach(async () => {
        wrapper = createComponent();
        await setNameField('issue');
      });

      it('displays an error', () => {
        expect(findFieldErrors('name')).toContain('Stage name already exists');
      });

      it('clears the error when the field changes', async () => {
        await setNameField('not an issue');

        expect(findFieldErrors('name')).not.toContain('Stage name already exists');
      });
    });
  });

  describe('End event', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('sets an error if no start event is selected', () => {
      expect(findFieldErrors('endEventIdentifier')).toContain('Please select a start event first');
    });

    it('clears error when a start event is selected', async () => {
      await setStartEvent();
      expect(findFieldErrors('endEventIdentifier')).not.toContain(
        'Please select a start event first',
      );
    });

    describe('with a end event selected and a change to the start event', () => {
      beforeEach(async () => {
        wrapper = createComponent();
        await setFields(minimumFields);
      });

      it('warns that the start event changed', async () => {
        await setStartEvent('');
        expect(findFieldErrors('endEventIdentifier')).toContain(
          'Please select a start event first',
        );
      });

      it('warns if the current start and end event pair is not valid', async () => {
        await setFields({ startEventIdentifier: 'fake_event_id' });

        expect(findFieldErrors('endEventIdentifier')).toContain(
          'Start event changed, please select a valid end event',
        );
      });

      it('will disable the submit button until a valid endEvent is selected', async () => {
        expect(findSubmitButton().props('disabled')).toBe(false);
        await setEndEvent('');
        expect(findSubmitButton().props('disabled')).toBe(true);
      });
    });
  });

  describe('Add stage button', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('has text `Add stage`', () => {
      expect(findSubmitButton().text()).toEqual('Add stage');
    });

    describe('with all fields set', () => {
      beforeEach(async () => {
        wrapper = createComponent();
        await setFields();
      });

      it('is enabled', () => {
        expect(findSubmitButton().props('disabled')).toBe(false);
      });

      it('does not emit an event until the button is clicked', () => {
        expect(findEvent(STAGE_ACTIONS.CREATE)).toBeUndefined();
      });

      it(`emits a ${STAGE_ACTIONS.CREATE} event when clicked`, async () => {
        findSubmitButton().vm.$emit('click');
        await wrapper.vm.$nextTick();

        expect(findEvent(STAGE_ACTIONS.CREATE)).toHaveLength(1);
      });

      it(`${STAGE_ACTIONS.CREATE} event receives the latest data`, async () => {
        const newData = {
          name: 'Cool stage',
          start_event_identifier: ISSUE_CREATED,
          end_event_identifier: ISSUE_CLOSED,
        };
        setFields(newData);

        findSubmitButton().vm.$emit('click');
        await wrapper.vm.$nextTick();

        expect(findEvent(STAGE_ACTIONS.CREATE)[0][0]).toMatchObject(newData);
      });
    });
  });

  describe('Cancel button', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('is disabled by default', async () => {
      expect(findCancelButton().props('disabled')).toBe(true);
    });

    it('is enabled when the form is dirty', async () => {
      await setNameField('Cool stage');
      expect(findCancelButton().props('disabled')).toBe(false);
    });

    it('will reset the fields when clicked', async () => {
      await setFields();

      findCancelButton().vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(wrapper.vm.fields).toMatchObject({
        name: null,
        startEventIdentifier: null,
        startEventLabelId: null,
        endEventIdentifier: null,
        endEventLabelId: null,
      });
    });

    it('does not emit an event until the button is clicked', () => {
      expect(findEvent('cancel')).toBeUndefined();
    });

    it('will emit the `cancel` event when clicked', async () => {
      await setFields();

      findCancelButton().vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(findEvent('cancel')).toHaveLength(1);
    });
  });

  describe('isSavingCustomStage=true', () => {
    beforeEach(async () => {
      wrapper = createComponent({
        initialState: {
          isSavingCustomStage: true,
        },
      });
      await wrapper.vm.$nextTick();
    });

    it('displays a loading icon', () => {
      expect(findSubmitButton().html()).toMatchSnapshot();
    });
  });

  describe('Editing a custom stage', () => {
    beforeEach(async () => {
      wrapper = createComponent({
        initialState: {
          isEditingCustomStage: true,
          formInitialData,
        },
      });
    });

    it('Cancel button will reset the fields to initial state when clicked', async () => {
      await setFields(minimumFields);

      findCancelButton().vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(wrapper.vm.fields).toEqual({ ...formInitialData });
    });

    describe('Update stage button', () => {
      it('has text `Update stage`', () => {
        expect(findSubmitButton().text('value')).toEqual('Update stage');
      });

      it('is disabled by default', () => {
        expect(findSubmitButton().props('disabled')).toBe(true);
      });

      it('is enabled when a field is changed and fields are valid', async () => {
        await setFields(minimumFields);
        expect(findSubmitButton().props('disabled')).toBe(false);
      });

      it('is disabled when a field is changed but fields are incomplete', async () => {
        await setFields({ name: '' });
        expect(findSubmitButton().props('disabled')).toBe(true);
      });

      it('does not emit an event until the button is clicked', () => {
        expect(findEvent(STAGE_ACTIONS.UPDATE)).toBeUndefined();
      });

      it(`emits a ${STAGE_ACTIONS.UPDATE} event when clicked`, async () => {
        await setFields({ name: 'Cool updated form' });

        findSubmitButton().vm.$emit('click');
        await wrapper.vm.$nextTick();

        expect(findEvent(STAGE_ACTIONS.UPDATE)).toHaveLength(1);
      });

      it('`submit` event receives the latest data', async () => {
        await setFields({ name: 'Cool updated form' });

        findSubmitButton().vm.$emit('click');
        await wrapper.vm.$nextTick();

        const submitted = findEvent(STAGE_ACTIONS.UPDATE)[0];
        expect(submitted).not.toEqual([formInitialData]);
        expect(submitted).toEqual([
          convertObjectPropsToSnakeCase({ ...formInitialData, name: 'Cool updated form' }),
        ]);
      });
    });

    describe('isSavingCustomStage=true', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialState: { isEditingCustomStage: true, isSavingCustomStage: true },
        });
      });

      it('displays a loading icon', () => {
        expect(findSubmitButton().html()).toMatchSnapshot();
      });
    });
  });

  describe('With initial errors', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialState: {
          formErrors: customStageFormErrors,
        },
      });
    });

    it('renders the errors for the relevant fields', () => {
      expect(findFieldErrors('name')).toEqual(['is reserved', 'cant be blank']);
      expect(findFieldErrors('startEventIdentifier')).toEqual(['cant be blank']);
    });
  });

  describe('recover stage dropdown', () => {
    describe('without hidden stages', () => {
      it('has the recover stage dropdown', () => {
        expect(findRecoverStageDropdown().exists()).toBe(true);
      });

      it('has no stages available to recover', async () => {
        expect(findRecoverStageDropdown().text()).toContain(
          'All default stages are currently visible',
        );
      });
    });

    describe('with hidden stages', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialRootGetters: {
            hiddenStages: () => [
              {
                id: 'my-stage',
                title: 'My default stage',
                hidden: true,
              },
            ],
          },
        });
      });

      it('has stages available to recover', async () => {
        const txt = findRecoverStageDropdown().text();
        expect(txt).not.toContain('All default stages are currently visible');
        expect(txt).toContain('My default stage');
      });

      it(`emits the ${STAGE_ACTIONS.UPDATE} action when clicking on a stage to recover`, async () => {
        findRecoverStageDropdown().find(GlDropdownItem).vm.$emit('click');
        await wrapper.vm.$nextTick();

        expect(wrapper.emitted()).toEqual({
          [STAGE_ACTIONS.UPDATE]: [[{ hidden: false, id: 'my-stage' }]],
        });
      });
    });
  });
});
