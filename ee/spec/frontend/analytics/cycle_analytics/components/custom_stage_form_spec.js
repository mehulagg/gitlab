import Vue from 'vue';
import { mount } from '@vue/test-utils';
import CustomStageForm from 'ee/analytics/cycle_analytics/components/custom_stage_form.vue';
import { STAGE_ACTIONS } from 'ee/analytics/cycle_analytics/constants';
import {
  groupLabels,
  customStageEvents as events,
  labelStartEvent,
  labelStopEvent,
  customStageStartEvents as startEvents,
  customStageStopEvents as stopEvents,
} from '../mock_data';

const initData = {
  id: 74,
  name: 'Cool stage pre',
  startEventIdentifier: labelStartEvent.identifier,
  startEventLabelId: groupLabels[0].id,
  endEventIdentifier: labelStopEvent.identifier,
  endEventLabelId: groupLabels[1].id,
};

describe('CustomStageForm', () => {
  function createComponent(props) {
    return mount(CustomStageForm, {
      propsData: {
        events,
        labels: groupLabels,
        ...props,
      },
      sync: false,
    });
  }

  let wrapper = null;
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

  describe('Empty form', () => {
    beforeEach(() => {
      wrapper = createComponent({}, false);
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe.each([
      ['Name', sel.name, true],
      ['Start event', sel.startEvent, true],
      ['Stop event', sel.endEvent, false],
      ['Submit', sel.submit, false],
      ['Cancel', sel.cancel, false],
    ])('by default', (field, $sel, enabledState) => {
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

    describe('Start event', () => {
      describe('with events', () => {
        beforeEach(() => {
          wrapper = createComponent({}, false);
        });

        afterEach(() => {
          wrapper.destroy();
        });

        it('selects events with canBeStartEvent=true for the start events dropdown', () => {
          const select = wrapper.find(sel.startEvent);
          expect(select.html()).toMatchSnapshot();
        });

        it('does not select events with canBeStartEvent=false for the start events dropdown', () => {
          const select = wrapper.find(sel.startEvent);
          expect(select.html()).toMatchSnapshot();

          stopEvents
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
          wrapper = createComponent({}, false);
        });

        afterEach(() => {
          wrapper.destroy();
        });

        it('is hidden by default', () => {
          expect(wrapper.find(sel.startEventLabel).exists()).toEqual(false);
        });

        it('will display the start event label field if a label event is selected', done => {
          wrapper.setData({
            fields: {
              startEventIdentifier: labelStartEvent.identifier,
            },
          });

          Vue.nextTick(() => {
            expect(wrapper.find(sel.startEventLabel).exists()).toEqual(true);
            done();
          });
        });

        it('will set the "startEventLabelId" field when selected', done => {
          const selectedLabelId = groupLabels[0].id;
          expect(wrapper.vm.fields.startEventLabelId).toEqual(null);

          wrapper.find(sel.startEvent).setValue(labelStartEvent.identifier);
          Vue.nextTick(() => {
            wrapper
              .find(sel.startEventLabel)
              .findAll('.dropdown-item')
              .at(1) // item at index 0 is 'select a label'
              .trigger('click');

            Vue.nextTick(() => {
              expect(wrapper.vm.fields.startEventLabelId).toEqual(selectedLabelId);
              done();
            });
          });
        });
      });
    });

    describe('Stop event', () => {
      const index = 2;
      const currAllowed = startEvents[index].allowedEndEvents;

      beforeEach(() => {
        wrapper = createComponent({}, false);
      });

      it('notifies that a start event needs to be selected first', () => {
        expect(wrapper.text()).toContain('Please select a start event first');
      });

      it('clears notification when a start event is selected', done => {
        selectDropdownOption(wrapper, sel.startEvent, 1);
        Vue.nextTick(() => {
          expect(wrapper.text()).not.toContain('Please select a start event first');
          done();
        });
      });

      it('is enabled when a start event is selected', done => {
        const el = wrapper.find(sel.endEvent);
        expect(el.attributes('disabled')).toEqual('disabled');

        selectDropdownOption(wrapper, sel.startEvent, 1);
        Vue.nextTick(() => {
          expect(el.attributes('disabled')).toBeUndefined();
          done();
        });
      });

      it('will update the list of stop events when a start event is changed', done => {
        let stopOptions = wrapper.find(sel.endEvent).findAll('option');
        const selectedStartEventIndex = 1;
        const selectedStartEvent = startEvents[selectedStartEventIndex];
        expect(stopOptions.length).toEqual(1);

        selectDropdownOption(wrapper, sel.startEvent, selectedStartEventIndex);

        Vue.nextTick(() => {
          stopOptions = wrapper.find(sel.endEvent);
          selectedStartEvent.allowedEndEvents.forEach(identifier => {
            expect(stopOptions.html()).toContain(identifier);
          });
          done();
        });
      });

      it('will display all the valid stop events', done => {
        let stopOptions = wrapper.find(sel.endEvent).findAll('option');
        const possibleEndEvents = stopEvents.filter(ev => currAllowed.includes(ev.identifier));

        expect(stopOptions.at(0).html()).toEqual('<option value="">Select stop event</option>');

        selectDropdownOption(wrapper, sel.startEvent, index);

        Vue.nextTick(() => {
          stopOptions = wrapper.find(sel.endEvent);

          possibleEndEvents.forEach(({ name, identifier }) => {
            expect(stopOptions.html()).toContain(`<option value="${identifier}">${name}</option>`);
          });
          done();
        });
      });

      it('will not display stop events that are not in the list of allowed stop events', done => {
        let stopOptions = wrapper.find(sel.endEvent).findAll('option');
        const excludedEndEvents = stopEvents.filter(ev => !currAllowed.includes(ev.identifier));

        expect(stopOptions.at(0).html()).toEqual('<option value="">Select stop event</option>');

        selectDropdownOption(wrapper, sel.startEvent, index);

        Vue.nextTick(() => {
          stopOptions = wrapper.find(sel.endEvent);

          excludedEndEvents.forEach(({ name, identifier }) => {
            expect(wrapper.find(sel.endEvent).html()).not.toHaveHtml(
              `<option value="${identifier}">${name}</option>`,
            );
          });
          done();
        });
      });

      describe('with a stop event selected and a change to the start event', () => {
        beforeEach(() => {
          wrapper = createComponent({}, false);

          wrapper.setData({
            fields: {
              name: 'Cool stage',
              startEventIdentifier: 'issue_created',
              startEventLabelId: null,
              endEventIdentifier: 'issue_stage_end',
              endEventLabelId: null,
            },
          });
        });

        afterEach(() => {
          wrapper.destroy();
        });

        it('will notify if the current start and stop event pair is not valid', done => {
          expect(wrapper.find(sel.invalidFeedback).exists()).toEqual(false);

          selectDropdownOption(wrapper, sel.startEvent, 2);

          Vue.nextTick(() => {
            expect(wrapper.find(sel.invalidFeedback).exists()).toEqual(true);
            expect(wrapper.find(sel.invalidFeedback).text()).toContain(
              'Start event changed, please select a valid stop event',
            );
            done();
          });
        });

        it('will update the list of stop events', done => {
          const se = wrapper.vm.endEventOptions;
          selectDropdownOption(wrapper, sel.startEvent, 2);
          Vue.nextTick(() => {
            expect(se[1].value).not.toEqual(wrapper.vm.endEventOptions[1].value);
            done();
          });
        });

        it('will disable the submit button until a valid endEvent is selected', done => {
          selectDropdownOption(wrapper, sel.startEvent, 2);
          Vue.nextTick(() => {
            expect(wrapper.find(sel.submit).attributes('disabled')).toEqual('disabled');
            done();
          });
        });
      });

      describe('Stop event label', () => {
        beforeEach(() => {
          wrapper = createComponent({}, false);
        });

        afterEach(() => {
          wrapper.destroy();
        });

        it('is hidden by default', () => {
          expect(wrapper.find(sel.startEventLabel).exists()).toEqual(false);
        });

        it('will display the stop event label field if a label event is selected', done => {
          expect(wrapper.find(sel.endEventLabel).exists()).toEqual(false);

          wrapper.setData({
            fields: {
              endEventIdentifier: labelStopEvent.identifier,
              startEventIdentifier: labelStartEvent.identifier,
            },
          });

          Vue.nextTick(() => {
            expect(wrapper.find(sel.endEventLabel).exists()).toEqual(true);
            done();
          });
        });

        it('will set the "endEventLabelId" field when selected', done => {
          const selectedLabelId = groupLabels[1].id;
          expect(wrapper.vm.fields.endEventLabelId).toEqual(null);

          wrapper.setData({
            fields: {
              startEventIdentifier: labelStartEvent.identifier,
              endEventIdentifier: labelStopEvent.identifier,
            },
          });

          Vue.nextTick(() => {
            wrapper
              .find(sel.endEventLabel)
              .findAll('.dropdown-item')
              .at(2) // item at index 0 is 'select a label'
              .trigger('click');

            Vue.nextTick(() => {
              expect(wrapper.vm.fields.endEventLabelId).toEqual(selectedLabelId);
              done();
            });
          });
        });
      });
    });

    describe('Add stage button', () => {
      beforeEach(() => {
        wrapper = createComponent({}, false);

        selectDropdownOption(wrapper, sel.startEvent, 1);

        return Vue.nextTick(() => {
          selectDropdownOption(wrapper, sel.endEvent, 1);
          return Vue.nextTick();
        });
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('has text `Add stage`', () => {
        expect(wrapper.find(sel.submit).text('value')).toEqual('Add stage');
      });

      it('is enabled when all required fields are filled', done => {
        const btn = wrapper.find(sel.submit);

        expect(btn.attributes('disabled')).toEqual('disabled');
        wrapper.find(sel.name).setValue('Cool stage');

        Vue.nextTick(() => {
          expect(btn.attributes('disabled')).toBeUndefined();
          done();
        });
      });

      describe('with all fields set', () => {
        const startEventIndex = 2;
        const stopEventIndex = 1;

        beforeEach(() => {
          wrapper = createComponent({}, false);

          selectDropdownOption(wrapper, sel.startEvent, startEventIndex);

          return Vue.nextTick()
            .then(() => {
              selectDropdownOption(wrapper, sel.endEvent, stopEventIndex);
              return Vue.nextTick();
            })
            .then(() => {
              wrapper.find(sel.name).setValue('Cool stage');
              return Vue.nextTick();
            });
        });

        afterEach(() => {
          wrapper.destroy();
        });

        it(`emits a ${STAGE_ACTIONS.CREATE} event when clicked`, done => {
          let event = findEvent(STAGE_ACTIONS.CREATE);
          expect(event).toBeUndefined();

          wrapper.find(sel.submit).trigger('click');

          Vue.nextTick(() => {
            event = findEvent(STAGE_ACTIONS.CREATE);
            expect(event).toBeTruthy();
            expect(event.length).toEqual(1);
            done();
          });
        });

        it(`${STAGE_ACTIONS.CREATE} event receives the latest data`, () => {
          const startEv = startEvents[startEventIndex];
          const selectedStopEvent = getDropdownOption(wrapper, sel.endEvent, stopEventIndex);

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
          return Vue.nextTick().then(() => {
            event = findEvent(STAGE_ACTIONS.CREATE);
            expect(event[0]).toEqual(res);
          });
        });
      });
    });

    describe('Cancel button', () => {
      beforeEach(() => {
        wrapper = createComponent({}, false);
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('is enabled when the form is dirty', done => {
        const btn = wrapper.find(sel.cancel);

        expect(btn.attributes('disabled')).toEqual('disabled');
        wrapper.find(sel.name).setValue('Cool stage');

        Vue.nextTick(() => {
          expect(btn.attributes('disabled')).toBeUndefined();
          done();
        });
      });

      it('will reset the fields when clicked', done => {
        wrapper.setData({
          fields: {
            name: 'Cool stage pre',
            startEventIdentifier: labelStartEvent.identifier,
            endEventIdentifier: labelStopEvent.identifier,
          },
        });

        Vue.nextTick(() => {
          wrapper.find(sel.cancel).trigger('click');

          Vue.nextTick(() => {
            expect(wrapper.vm.fields).toEqual({
              id: null,
              name: null,
              startEventIdentifier: null,
              startEventLabelId: null,
              endEventIdentifier: null,
              endEventLabelId: null,
            });
            done();
          });
        });
      });

      it('will emit the `cancel` event when clicked', done => {
        let ev = findEvent('cancel');
        expect(ev).toBeUndefined();

        wrapper.setData({
          fields: {
            name: 'Cool stage pre',
          },
        });

        Vue.nextTick(() => {
          wrapper.find(sel.cancel).trigger('click');

          Vue.nextTick(() => {
            ev = findEvent('cancel');
            expect(ev).toBeTruthy();
            expect(ev.length).toEqual(1);
            done();
          });
        });
      });
    });

    describe('isSavingCustomStage=true', () => {
      beforeEach(() => {
        wrapper = createComponent(
          {
            isSavingCustomStage: true,
          },
          false,
        );
      });

      it('displays a loading icon', () => {
        expect(wrapper.find(sel.submit).html()).toMatchSnapshot();
      });
    });
  });

  describe('Editing a custom stage', () => {
    beforeEach(() => {
      wrapper = createComponent(
        {
          isEditingCustomStage: true,
          initialFields: {
            ...initData,
          },
        },
        false,
      );

      wrapper.setData({
        fields: {
          ...initData,
        },
      });

      return Vue.nextTick();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('Cancel button', () => {
      it('will reset the fields to initial state when clicked', done => {
        wrapper.setData({
          fields: {
            name: 'Cool stage pre',
            startEventIdentifier: labelStartEvent.identifier,
            endEventIdentifier: labelStopEvent.identifier,
          },
        });

        Vue.nextTick(() => {
          wrapper.find(sel.cancel).trigger('click');

          Vue.nextTick(() => {
            expect(wrapper.vm.fields).toEqual({
              ...initData,
            });
            done();
          });
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

      it('is enabled when a field is changed and fields are valid', done => {
        wrapper.setData({
          fields: {
            name: 'Cool updated form',
          },
        });

        Vue.nextTick(() => {
          expect(wrapper.find(sel.submit).attributes('disabled')).toBeUndefined();
          done();
        });
      });

      it('is disabled when a field is changed but fields are incomplete', done => {
        wrapper.setData({
          fields: {
            name: '',
          },
        });

        Vue.nextTick(() => {
          expect(wrapper.find(sel.submit).attributes('disabled')).toEqual('disabled');
          done();
        });
      });

      it(`emits a ${STAGE_ACTIONS.UPDATE} event when clicked`, done => {
        let ev = findEvent(STAGE_ACTIONS.UPDATE);
        expect(ev).toBeUndefined();

        wrapper.setData({
          fields: {
            name: 'Cool updated form',
          },
        });

        Vue.nextTick(() => {
          wrapper.find(sel.submit).trigger('click');

          Vue.nextTick(() => {
            ev = findEvent(STAGE_ACTIONS.UPDATE);
            expect(ev).toBeTruthy();
            expect(ev.length).toEqual(1);
            done();
          });
        });
      });

      it('`submit` event receives the latest data', done => {
        wrapper.setData({
          fields: {
            name: 'Cool updated form',
          },
        });

        Vue.nextTick(() => {
          wrapper.find(sel.submit).trigger('click');

          Vue.nextTick(() => {
            const submitted = findEvent(STAGE_ACTIONS.UPDATE)[0];
            expect(submitted).not.toEqual([initData]);
            expect(submitted).toEqual([
              {
                id: initData.id,
                start_event_identifier: labelStartEvent.identifier,
                start_event_label_id: groupLabels[0].id,
                end_event_identifier: labelStopEvent.identifier,
                end_event_label_id: groupLabels[1].id,
                name: 'Cool updated form',
              },
            ]);

            done();
          });
        });
      });
    });

    describe('isSavingCustomStage=true', () => {
      beforeEach(() => {
        wrapper = createComponent(
          {
            isEditingCustomStage: true,
            initialFields: {
              ...initData,
            },
            isSavingCustomStage: true,
          },
          false,
        );
      });

      it('displays a loading icon', () => {
        expect(wrapper.find(sel.submit).html()).toMatchSnapshot();
      });
    });
  });
});
