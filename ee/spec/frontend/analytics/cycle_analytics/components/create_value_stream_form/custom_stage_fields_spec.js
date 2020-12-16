import { shallowMount } from '@vue/test-utils';
import { GlFormSelect, GlFormInput } from '@gitlab/ui';
import CustomStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/custom_stage_fields.vue';
import LabelsSelector from 'ee/analytics/cycle_analytics/components/labels_selector.vue';
import { getLabelEventsIdentifiers } from 'ee/analytics/cycle_analytics/utils';
import {
  findName,
  findStartEvent,
  findStartEventLabel,
  findEndEvent,
  findEndEventLabel,
  formatStartEventOpts,
  formatEndEventOpts,
} from './helpers';
import { emptyState, emptyErrorsState, firstLabel } from './mock_data';
import {
  customStageEvents as events,
  customStageLabelEvents,
  labelStartEvent,
  labelStopEvent,
  customStageStopEvents as endEvents,
} from '../../mock_data';

const startEventOptions = formatStartEventOpts(events);
const endEventOptions = formatEndEventOpts(events);

describe('CustomStageFields', () => {
  function createComponent({
    fields = emptyState,
    errors = emptyErrorsState,
    labelEvents = getLabelEventsIdentifiers(customStageLabelEvents),
    stubs = {},
    props = {},
  } = {}) {
    return shallowMount(CustomStageFields, {
      propsData: {
        fields,
        errors,
        events,
        labelEvents,
        ...props,
      },
      stubs: {
        'labels-selector': false,
        ...stubs,
      },
    });
  }

  let wrapper = null;

  const getSelectField = dropdownEl => dropdownEl.find(GlFormSelect);
  const getLabelSelect = dropdownEl => dropdownEl.find(LabelsSelector);

  const findNameField = _wrapper => findName(_wrapper).find(GlFormInput);
  const findStartEventField = _wrapper => getSelectField(findStartEvent(_wrapper));
  const findEndEventField = _wrapper => getSelectField(findEndEvent(_wrapper));
  const findStartEventLabelField = _wrapper => getLabelSelect(findStartEventLabel(_wrapper));
  const findEndEventLabelField = _wrapper => getLabelSelect(findEndEventLabel(_wrapper));

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each([
    ['Name', findNameField, undefined],
    ['Start event', findStartEventField, undefined],
    ['End event', findEndEventField, 'true'],
  ])('Default state', (field, finder, fieldDisabledValue) => {
    it(`field '${field}' is disabled ${fieldDisabledValue ? 'true' : 'false'}`, () => {
      const $el = finder(wrapper);
      expect($el.exists()).toBe(true);
      expect($el.attributes('disabled')).toBe(fieldDisabledValue);
    });
  });

  describe.each([
    ['Start event label', findStartEventLabel],
    ['End event label', findStartEventLabel],
  ])('Default state', (field, finder) => {
    it(`field '${field}' is hidden by default`, () => {
      expect(finder(wrapper).exists()).toBe(false);
    });
  });

  describe('Fields', () => {
    it('emit update event when a field is changed', () => {
      expect(wrapper.emitted('update')).toBeUndefined();
      findNameField(wrapper).vm.$emit('input', 'Cool new stage');

      expect(wrapper.emitted('update')[0]).toEqual(['name', 'Cool new stage']);
    });
  });

  describe('Start event', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('selects the correct start events for the start events dropdown', () => {
      expect(wrapper.vm.startEvents).toEqual(startEventOptions);
    });

    it('does not select end events for the start events dropdown', () => {
      expect(wrapper.vm.startEvents).not.toEqual(endEventOptions);
    });

    describe('start event label', () => {
      beforeEach(() => {
        wrapper = createComponent({
          fields: {
            startEventIdentifier: labelStartEvent.identifier,
          },
        });
      });

      it('will display the start event label field if a label event is selected', () => {
        expect(findStartEventLabel(wrapper).exists()).toEqual(true);
      });

      it('will emit the `update` event when the start event label field when selected', async () => {
        expect(wrapper.emitted().update).toBeUndefined();

        findStartEventLabelField(wrapper).vm.$emit('selectLabel', firstLabel.id);

        expect(wrapper.emitted().update[0]).toEqual(['startEventLabelId', firstLabel.id]);
      });
    });
  });

  describe('End event', () => {
    const possibleEndEvents = endEvents.filter(ev =>
      labelStartEvent.allowedEndEvents.includes(ev.identifier),
    );

    const allowedEndEventOpts = formatEndEventOpts(possibleEndEvents);

    beforeEach(() => {
      wrapper = createComponent();
    });

    it('selects the end events based on the start event', () => {
      expect(wrapper.vm.endEvents).toEqual(allowedEndEventOpts);
    });

    it('does not select start events for the end events dropdown', () => {
      expect(wrapper.vm.endEvents).not.toEqual(startEventOptions);
    });

    describe('end event label', () => {
      beforeEach(() => {
        wrapper = createComponent({
          fields: {
            startEventIdentifier: labelStartEvent.identifier,
            endEventIdentifier: labelStopEvent.identifier,
          },
        });
      });

      it('will display the start event label field if a label event is selected', () => {
        expect(findEndEventLabel(wrapper).exists()).toEqual(true);
      });

      it('will emit the `update` event when the start event label field when selected', async () => {
        expect(wrapper.emitted().update).toBeUndefined();

        findEndEventLabelField(wrapper).vm.$emit('selectLabel', firstLabel.id);

        expect(wrapper.emitted().update[0]).toEqual(['endEventLabelId', firstLabel.id]);
      });
    });
  });
});
