import Vuex from 'vuex';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import customStagesStore from 'ee/analytics/cycle_analytics/store/modules/custom_stages';
import { createLocalVue, mount } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';
import CustomStageForm, {
  initializeFormData,
} from 'ee/analytics/cycle_analytics/components/custom_stage_form.vue';
import { STAGE_ACTIONS } from 'ee/analytics/cycle_analytics/constants';
import {
  endpoints,
  groupLabels,
  customStageEvents as events,
  labelStartEvent,
  labelStopEvent,
  customStageStartEvents as startEvents,
  customStageStopEvents as stopEvents,
  customStageFormErrors,
} from '../mock_data';

const formInitialData = {
  id: 74,
  name: 'Cool stage pre',
  startEventIdentifier: labelStartEvent.identifier,
  startEventLabelId: groupLabels[0].id,
  endEventIdentifier: labelStopEvent.identifier,
  endEventLabelId: groupLabels[1].id,
};

const MERGE_REQUEST_CREATED = 'merge_request_created';
const MERGE_REQUEST_CLOSED = 'merge_request_closed';

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
    return mount(CustomStageForm, {
      localVue,
      store: fakeStore({ initialState, initialRootGetters }),
      propsData: {
        events,
        ...props,
      },
      stubs: {
        'labels-selector': false,
        ...stubs,
      },
    });
  }

  let wrapper = null;
  let mock;

  const findEvent = ev => wrapper.emitted()[ev];

  const sel = {
    name: '[name="custom-stage-name"]',
    startEvent: '[name="custom-stage-start-event"]',
    startEventLabel: '[name="custom-stage-start-event-label"]',
    endEvent: '[name="custom-stage-stop-event"]',
    endEventLabel: '[name="custom-stage-stop-event-label"]',
    submit: '.js-save-stage',
    cancel: '.js-save-stage-cancel',
    invalidFeedback: '.invalid-feedback',
    recoverStageDropdown: '.js-recover-hidden-stage-dropdown',
    recoverStageDropdownTrigger: '.js-recover-hidden-stage-dropdown .dropdown-toggle',
    hiddenStageDropdownOption: '.js-recover-hidden-stage-dropdown .dropdown-item',
  };

  function getDropdownOption(_wrapper, dropdown, index) {
    return _wrapper
      .find(dropdown)
      .findAll('option')
      .at(index);
  }

  function selectDropdownOption(_wrapper, dropdown, index) {
    getDropdownOption(_wrapper, dropdown, index).setSelected();
  }

  // Valid start and end event pair: merge request created - merge request closed
  const mergeRequestCreatedIndex = startEvents.findIndex(
    e => e.identifier === MERGE_REQUEST_CREATED,
  );
  const mergeRequestCreatedDropdownIndex = mergeRequestCreatedIndex;
  const mergeReqestCreatedEvent = startEvents[mergeRequestCreatedIndex];
  const mergeRequestClosedDropdownIndex = mergeReqestCreatedEvent.allowedEndEvents.findIndex(
    e => e === MERGE_REQUEST_CLOSED,
  );

  function setEventDropdowns({
    startEventDropdownIndex = mergeRequestCreatedDropdownIndex,
    stopEventDropdownIndex = mergeRequestClosedDropdownIndex,
  } = {}) {
    selectDropdownOption(wrapper, sel.startEvent, startEventDropdownIndex);
    return wrapper.vm.$nextTick().then(() => {
      selectDropdownOption(wrapper, sel.endEvent, stopEventDropdownIndex);
    });
  }

  const findNameField = _wrapper => _wrapper.find({ ref: 'name' });
  const findNameFieldInput = _wrapper => _wrapper.find(sel.name);

  function setNameField(_wrapper, value = '') {
    findNameFieldInput(_wrapper).setValue(value);
    findNameFieldInput(_wrapper).trigger('change');
    return _wrapper.vm.$nextTick();
  }

  const mockGroupLabelsRequest = () =>
    new MockAdapter(axios).onGet(endpoints.groupLabels).reply(200, groupLabels);

  beforeEach(() => {
    mock = mockGroupLabelsRequest();
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe.each([
    ['Name', sel.name, true],
    ['Start event', sel.startEvent, true],
    ['Stop event', sel.endEvent, false],
    ['Submit', sel.submit, false],
    ['Cancel', sel.cancel, false],
  ])('Default state', (field, $sel, enabledState) => {
    const state = enabledState ? 'enabled' : 'disabled';
    it(`field '${field}' is ${state}`, () => {
      const el = wrapper.find($sel);
      expect(el.exists()).toEqual(true);
      if (!enabledState) {
        expect(el.attributes('disabled')).toEqual('disabled');
      } else {
        expect(el.attributes('disabled')).toBeUndefined();
      }
    });
  });

  describe('Helper text', () => {
    it('displays the manual ordering helper text', () => {
      expect(wrapper.text()).toContain(
        'Note: Once a custom stage has been added you can re-order stages by dragging them into the desired position.',
      );
    });
  });

  describe('Name', () => {
    describe('with a reserved name', () => {
      beforeEach(() => {
        wrapper = createComponent();
        return setNameField(wrapper, 'issue');
      });

      it('displays an error', () => {
        expect(findNameField(wrapper).text()).toContain('Stage name already exists');
      });

      it('clears the error when the field changes', () => {
        return setNameField(wrapper, 'not an issue').then(() => {
          expect(findNameField(wrapper).text()).not.toContain('Stage name already exists');
        });
      });
    });
  });

  describe('Start event', () => {
    describe('with events', () => {
      beforeEach(() => {
        wrapper = createComponent();
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('selects events with canBeStartEvent=true for the start events dropdown', () => {
        const select = wrapper.find(sel.startEvent);

        events
          .filter(ev => ev.canBeStartEvent)
          .forEach(ev => {
            expect(select.html()).toHaveHtml(
              `<option value="${ev.identifier}">${ev.name}</option>`,
            );
          });
      });

      it('does not select events with canBeStartEvent=false for the start events dropdown', () => {
        const select = wrapper.find(sel.startEvent);

        events
          .filter(ev => !ev.canBeStartEvent)
          .forEach(ev => {
            expect(select.html()).not.toHaveHtml(
              `<option value="${ev.identifier}">${ev.name}</option>`,
            );
          });
      });
    });

    describe('start event label', () => {
      beforeEach(() => {
        mock = mockGroupLabelsRequest();
        wrapper = createComponent();

        return wrapper.vm.$nextTick();
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('is hidden by default', () => {
        expect(wrapper.find(sel.startEventLabel).exists()).toEqual(false);
      });

      it('will display the start event label field if a label event is selected', () => {
        wrapper.setData({
          fields: {
            startEventIdentifier: labelStartEvent.identifier,
          },
        });

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.startEventLabel).exists()).toEqual(true);
        });
      });

      it('will set the "startEventLabelId" field when selected', () => {
        const selectedLabelId = groupLabels[0].id;
        expect(wrapper.vm.fields.startEventLabelId).toEqual(null);

        wrapper.find(sel.startEvent).setValue(labelStartEvent.identifier);
        return waitForPromises()
          .then(() => {
            wrapper
              .find(sel.startEventLabel)
              .findAll('.dropdown-item')
              .at(1) // item at index 0 is 'select a label'
              .trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            expect(wrapper.vm.fields.startEventLabelId).toEqual(selectedLabelId);
          });
      });
    });
  });

  describe('Stop event', () => {
    const startEventArrayIndex = mergeRequestCreatedIndex;
    const startEventDropdownIndex = startEventArrayIndex + 1;
    const currAllowed = startEvents[startEventArrayIndex].allowedEndEvents;

    beforeEach(() => {
      wrapper = createComponent();
    });

    it('notifies that a start event needs to be selected first', () => {
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.text()).toContain('Please select a start event first');
      });
    });

    it('clears notification when a start event is selected', () => {
      selectDropdownOption(wrapper, sel.startEvent, startEventDropdownIndex);
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.text()).not.toContain('Please select a start event first');
      });
    });

    it('is enabled when a start event is selected', () => {
      const el = wrapper.find(sel.endEvent);
      expect(el.attributes('disabled')).toEqual('disabled');

      selectDropdownOption(wrapper, sel.startEvent, startEventDropdownIndex);
      return wrapper.vm.$nextTick().then(() => {
        expect(el.attributes('disabled')).toBeUndefined();
      });
    });

    it('will update the list of stop events when a start event is changed', () => {
      let stopOptions = wrapper.find(sel.endEvent).findAll('option');
      const selectedStartEvent = startEvents[startEventDropdownIndex];
      expect(stopOptions).toHaveLength(1);

      selectDropdownOption(wrapper, sel.startEvent, startEventDropdownIndex);

      return wrapper.vm.$nextTick().then(() => {
        stopOptions = wrapper.find(sel.endEvent);
        selectedStartEvent.allowedEndEvents.forEach(identifier => {
          expect(stopOptions.html()).toContain(identifier);
        });
      });
    });

    it('will display all the valid stop events', () => {
      let stopOptions = wrapper.find(sel.endEvent).findAll('option');
      const possibleEndEvents = stopEvents.filter(ev => currAllowed.includes(ev.identifier));

      expect(stopOptions.at(0).html()).toEqual('<option value="">Select stop event</option>');

      selectDropdownOption(wrapper, sel.startEvent, startEventDropdownIndex);

      return wrapper.vm.$nextTick().then(() => {
        stopOptions = wrapper.find(sel.endEvent);

        possibleEndEvents.forEach(({ name, identifier }) => {
          expect(stopOptions.html()).toContain(`<option value="${identifier}">${name}</option>`);
        });
      });
    });

    it('will not display stop events that are not in the list of allowed stop events', () => {
      let stopOptions = wrapper.find(sel.endEvent).findAll('option');
      const excludedEndEvents = stopEvents.filter(ev => !currAllowed.includes(ev.identifier));

      expect(stopOptions.at(0).html()).toEqual('<option value="">Select stop event</option>');

      selectDropdownOption(wrapper, sel.startEvent, startEventArrayIndex + 1);

      return wrapper.vm.$nextTick().then(() => {
        stopOptions = wrapper.find(sel.endEvent);

        excludedEndEvents.forEach(({ name, identifier }) => {
          expect(wrapper.find(sel.endEvent).html()).not.toHaveHtml(
            `<option value="${identifier}">${name}</option>`,
          );
        });
      });
    });

    describe('with a stop event selected and a change to the start event', () => {
      beforeEach(() => {
        wrapper = createComponent();

        wrapper.setData({
          fields: {
            name: 'Cool stage',
            startEventIdentifier: MERGE_REQUEST_CREATED,
            startEventLabelId: null,
            endEventIdentifier: MERGE_REQUEST_CLOSED,
            endEventLabelId: null,
          },
        });
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('notifies that a start event needs to be selected first', () => {
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.text()).toContain('Please select a start event first');
        });
      });

      it('will notify if the current start and stop event pair is not valid', () => {
        selectDropdownOption(wrapper, sel.startEvent, 2);

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.invalidFeedback).exists()).toEqual(true);
          expect(wrapper.find(sel.invalidFeedback).text()).toContain(
            'Start event changed, please select a valid stop event',
          );
        });
      });

      it('will update the list of stop events', () => {
        const se = wrapper.vm.endEventOptions;
        selectDropdownOption(wrapper, sel.startEvent, 2);
        return wrapper.vm.$nextTick().then(() => {
          expect(se[1].value).not.toEqual(wrapper.vm.endEventOptions[1].value);
        });
      });

      it('will disable the submit button until a valid endEvent is selected', () => {
        selectDropdownOption(wrapper, sel.startEvent, 2);
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.submit).attributes('disabled')).toEqual('disabled');
        });
      });
    });

    describe('Stop event label', () => {
      beforeEach(() => {
        wrapper = createComponent();
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('is hidden by default', () => {
        expect(wrapper.find(sel.startEventLabel).exists()).toEqual(false);
      });

      it('will display the stop event label field if a label event is selected', () => {
        expect(wrapper.find(sel.endEventLabel).exists()).toEqual(false);

        wrapper.setData({
          fields: {
            endEventIdentifier: labelStopEvent.identifier,
            startEventIdentifier: labelStartEvent.identifier,
          },
        });

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.endEventLabel).exists()).toEqual(true);
        });
      });

      it('will set the "endEventLabelId" field when selected', () => {
        const selectedLabelId = groupLabels[1].id;
        expect(wrapper.vm.fields.endEventLabelId).toEqual(null);

        wrapper.setData({
          fields: {
            startEventIdentifier: labelStartEvent.identifier,
            endEventIdentifier: labelStopEvent.identifier,
          },
        });

        return waitForPromises()
          .then(() => {
            wrapper
              .find(sel.endEventLabel)
              .findAll('.dropdown-item')
              .at(2) // item at index 0 is 'select a label'
              .trigger('click');

            return wrapper.vm.$nextTick();
          })
          .then(() => {
            expect(wrapper.vm.fields.endEventLabelId).toEqual(selectedLabelId);
          });
      });
    });
  });

  describe('Add stage button', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('has text `Add stage`', () => {
      expect(wrapper.find(sel.submit).text()).toEqual('Add stage');
    });

    it('is enabled when all required fields are filled', () => {
      const btn = wrapper.find(sel.submit);

      expect(btn.attributes('disabled')).toEqual('disabled');
      wrapper.find(sel.name).setValue('Cool stage');

      return setEventDropdowns().then(() => {
        expect(btn.attributes('disabled')).toBeUndefined();
      });
    });

    describe('with all fields set', () => {
      const startEventDropdownIndex = 2;
      const startEventArrayIndex = startEventDropdownIndex - 1;
      const stopEventDropdownIndex = 1;

      beforeEach(() => {
        wrapper = createComponent();
        wrapper.find(sel.name).setValue('Cool stage');
        return wrapper.vm
          .$nextTick()
          .then(() => setEventDropdowns({ startEventDropdownIndex, stopEventDropdownIndex }));
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it(`emits a ${STAGE_ACTIONS.CREATE} event when clicked`, () => {
        let event = findEvent(STAGE_ACTIONS.CREATE);
        expect(event).toBeUndefined();

        wrapper.find(sel.submit).trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          event = findEvent(STAGE_ACTIONS.CREATE);
          expect(event).toBeTruthy();
          expect(event).toHaveLength(1);
        });
      });

      it(`${STAGE_ACTIONS.CREATE} event receives the latest data`, () => {
        const startEv = startEvents[startEventArrayIndex];
        const selectedStopEvent = getDropdownOption(wrapper, sel.endEvent, stopEventDropdownIndex);
        let event = findEvent(STAGE_ACTIONS.CREATE);
        expect(event).toBeUndefined();

        const res = [
          {
            id: null,
            name: 'Cool stage',
            start_event_identifier: startEv.identifier,
            start_event_label_id: null,
            end_event_identifier: selectedStopEvent.attributes('value'),
            end_event_label_id: null,
          },
        ];

        wrapper.find(sel.submit).trigger('click');
        return wrapper.vm.$nextTick().then(() => {
          event = findEvent(STAGE_ACTIONS.CREATE);
          expect(event[0]).toEqual(res);
        });
      });
    });
  });

  describe('Cancel button', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('is enabled when the form is dirty', () => {
      const btn = wrapper.find(sel.cancel);

      expect(btn.attributes('disabled')).toEqual('disabled');
      wrapper.find(sel.name).setValue('Cool stage');

      return wrapper.vm.$nextTick().then(() => {
        expect(btn.attributes('disabled')).toBeUndefined();
      });
    });

    it('will reset the fields when clicked', () => {
      wrapper.setData({
        fields: {
          name: 'Cool stage pre',
          startEventIdentifier: labelStartEvent.identifier,
          endEventIdentifier: labelStopEvent.identifier,
        },
      });

      return wrapper.vm
        .$nextTick()
        .then(() => {
          wrapper.find(sel.cancel).trigger('click');

          return wrapper.vm.$nextTick();
        })
        .then(() => {
          expect(wrapper.vm.fields).toEqual({
            id: null,
            name: null,
            startEventIdentifier: null,
            startEventLabelId: null,
            endEventIdentifier: null,
            endEventLabelId: null,
          });
        });
    });

    it('will emit the `cancel` event when clicked', () => {
      let ev = findEvent('cancel');
      expect(ev).toBeUndefined();

      wrapper.setData({
        fields: {
          name: 'Cool stage pre',
        },
      });

      return wrapper.vm
        .$nextTick()
        .then(() => {
          wrapper.find(sel.cancel).trigger('click');
          return wrapper.vm.$nextTick();
        })
        .then(() => {
          ev = findEvent('cancel');
          expect(ev).toBeTruthy();
          expect(ev).toHaveLength(1);
        });
    });
  });

  describe('isSavingCustomStage=true', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialState: {
          isSavingCustomStage: true,
        },
      });
      return wrapper.vm.$nextTick();
    });

    it('displays a loading icon', () => {
      expect(wrapper.find(sel.submit).html()).toMatchSnapshot();
    });
  });

  describe('Editing a custom stage', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialState: {
          isEditingCustomStage: true,
          formInitialData,
        },
      });

      return wrapper.vm.$nextTick();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('Cancel button', () => {
      it('will reset the fields to initial state when clicked', () => {
        wrapper.setData({
          fields: {
            name: 'Cool stage pre',
            startEventIdentifier: labelStartEvent.identifier,
            endEventIdentifier: labelStopEvent.identifier,
          },
        });

        return wrapper.vm
          .$nextTick()
          .then(() => {
            wrapper.find(sel.cancel).trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            expect(wrapper.vm.fields).toEqual({ ...formInitialData });
          });
      });
    });

    describe('Update stage button', () => {
      it('has text `Update stage`', () => {
        expect(wrapper.find(sel.submit).text('value')).toEqual('Update stage');
      });

      it('is disabled by default', () => {
        expect(wrapper.find(sel.submit).attributes('disabled')).toEqual('disabled');
      });

      it('is enabled when a field is changed and fields are valid', () => {
        wrapper.setData({
          fields: {
            name: 'Cool updated form',
          },
        });

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.submit).attributes('disabled')).toBeUndefined();
        });
      });

      it('is disabled when a field is changed but fields are incomplete', () => {
        wrapper.setData({
          fields: {
            name: '',
          },
        });

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.submit).attributes('disabled')).toEqual('disabled');
        });
      });

      it(`emits a ${STAGE_ACTIONS.UPDATE} event when clicked`, () => {
        let ev = findEvent(STAGE_ACTIONS.UPDATE);
        expect(ev).toBeUndefined();

        wrapper.setData({
          fields: {
            name: 'Cool updated form',
          },
        });

        return wrapper.vm
          .$nextTick()
          .then(() => {
            wrapper.find(sel.submit).trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            ev = findEvent(STAGE_ACTIONS.UPDATE);
            expect(ev).toBeTruthy();
            expect(ev).toHaveLength(1);
          });
      });

      it('`submit` event receives the latest data', () => {
        wrapper.setData({
          fields: {
            name: 'Cool updated form',
          },
        });

        return wrapper.vm
          .$nextTick()
          .then(() => {
            wrapper.find(sel.submit).trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            const submitted = findEvent(STAGE_ACTIONS.UPDATE)[0];
            expect(submitted).not.toEqual([formInitialData]);
            expect(submitted).toEqual([
              {
                id: formInitialData.id,
                start_event_identifier: labelStartEvent.identifier,
                start_event_label_id: groupLabels[0].id,
                end_event_identifier: labelStopEvent.identifier,
                end_event_label_id: groupLabels[1].id,
                name: 'Cool updated form',
              },
            ]);
          });
      });
    });

    describe('isSavingCustomStage=true', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialState: {
            isEditingCustomStage: true,
            isSavingCustomStage: true,
          },
        });
      });
      it('displays a loading icon', () => {
        expect(wrapper.find(sel.submit).html()).toMatchSnapshot();
      });
    });
  });

  describe('With errors', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialState: {
          formErrors: customStageFormErrors,
        },
      });

      return wrapper.vm.$nextTick();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders the errors for the relevant fields', () => {
      expect(wrapper.find({ ref: 'name' }).html()).toContain('is reserved');
      expect(wrapper.find({ ref: 'name' }).html()).toContain('cant be blank');
      expect(wrapper.find({ ref: 'startEventIdentifier' }).html()).toContain('cant be blank');
    });
  });

  describe('recover stage dropdown', () => {
    const formFieldStubs = {
      'gl-form-group': true,
      'gl-form-select': true,
      'labels-selector': true,
    };

    beforeEach(() => {
      wrapper = createComponent({
        stubs: formFieldStubs,
      });
    });

    describe('without hidden stages', () => {
      it('has the recover stage dropdown', () => {
        expect(wrapper.find(sel.recoverStageDropdown).exists()).toBe(true);
      });

      it('has no stages available to recover', () => {
        wrapper.find(sel.recoverStageDropdownTrigger).trigger('click');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(sel.recoverStageDropdown).text()).toContain(
            'All default stages are currently visible',
          );
        });
      });
    });

    describe('with hidden stages', () => {
      beforeEach(() => {
        wrapper = createComponent({
          stubs: formFieldStubs,
          initialRootGetters: {
            hiddenStages: () => [{ id: 'my-stage', title: 'My default stage', hidden: true }],
          },
        });
      });

      it('has stages available to recover', () => {
        wrapper.find(sel.recoverStageDropdownTrigger).trigger('click');
        return wrapper.vm.$nextTick().then(() => {
          const txt = wrapper.find(sel.recoverStageDropdown).text();
          expect(txt).not.toContain('All default stages are currently visible');
          expect(txt).toContain('My default stage');
        });
      });

      it(`emits the ${STAGE_ACTIONS.UPDATE} action when clicking on a stage to recover`, () => {
        wrapper.find(sel.recoverStageDropdownTrigger).trigger('click');
        return wrapper.vm.$nextTick().then(() => {
          wrapper
            .findAll(sel.hiddenStageDropdownOption)
            .at(0)
            .trigger('click');

          expect(wrapper.emitted()).toEqual({
            [STAGE_ACTIONS.UPDATE]: [[{ hidden: false, id: 'my-stage' }]],
          });
        });
      });
    });
  });

  describe('initializeFormData', () => {
    const emptyFieldState = {
      id: null,
      name: null,
      startEventIdentifier: null,
      startEventLabelId: null,
      endEventIdentifier: null,
      endEventLabelId: null,
    };

    const emptyErrorsState = {
      id: [],
      name: [],
      startEventIdentifier: [],
      startEventLabelId: [],
      endEventIdentifier: [],
      endEventLabelId: [],
    };

    describe('without a startEventIdentifier', () => {
      it('with no errors', () => {
        const res = initializeFormData({
          emptyFieldState,
          fields: {},
        });
        expect(res.fields).toEqual(emptyFieldState);
        expect(res.errors).toMatchObject({
          endEventIdentifier: ['Please select a start event first'],
        });
      });

      it('with field errors', () => {
        const res = initializeFormData({
          emptyFieldState,
          fields: {},
          errors: {
            name: ['is reserved'],
          },
        });
        expect(res.fields).toEqual(emptyFieldState);
        expect(res.errors).toMatchObject({
          endEventIdentifier: ['Please select a start event first'],
          name: ['is reserved'],
        });
      });
    });

    describe('with a startEventIdentifier', () => {
      it('with no errors', () => {
        const res = initializeFormData({
          emptyFieldState,
          fields: {
            startEventIdentifier: 'start-event',
          },
          errors: {},
        });
        expect(res.fields).toEqual({ ...emptyFieldState, startEventIdentifier: 'start-event' });
        expect(res.errors).toMatchObject({
          endEventIdentifier: [],
        });
      });

      it('with field errors', () => {
        const res = initializeFormData({
          emptyFieldState,
          fields: {
            startEventIdentifier: 'start-event',
          },
          errors: {
            name: ['is reserved'],
          },
        });
        expect(res.fields).toEqual({ ...emptyFieldState, startEventIdentifier: 'start-event' });
        expect(res.errors).toMatchObject({
          endEventIdentifier: [],
          name: ['is reserved'],
        });
      });
    });

    describe('with all fields set', () => {
      it('with no errors', () => {
        const res = initializeFormData({
          emptyFieldState,
          fields: {
            id: 1,
            name: 'cool-stage',
            startEventIdentifier: 'start-event',
            endEventIdentifier: 'end-event',
            startEventLabelId: 10,
            endEventLabelId: 20,
          },
          errors: {},
        });
        expect(res.fields).toEqual({
          id: 1,
          name: 'cool-stage',
          startEventIdentifier: 'start-event',
          endEventIdentifier: 'end-event',
          startEventLabelId: 10,
          endEventLabelId: 20,
        });
        expect(res.errors).toEqual(emptyErrorsState);
      });

      it('with field errors', () => {
        const res = initializeFormData({
          emptyFieldState,
          fields: {
            id: 1,
            name: 'cool-stage',
            startEventIdentifier: 'start-event',
            endEventIdentifier: 'end-event',
            startEventLabelId: 10,
            endEventLabelId: 20,
          },
          errors: {
            name: ['is reserved'],
          },
        });

        expect(res.fields).toEqual({
          id: 1,
          name: 'cool-stage',
          startEventIdentifier: 'start-event',
          endEventIdentifier: 'end-event',
          startEventLabelId: 10,
          endEventLabelId: 20,
        });
        expect(res.errors).toMatchObject({
          name: ['is reserved'],
        });
      });
    });
  });
});
