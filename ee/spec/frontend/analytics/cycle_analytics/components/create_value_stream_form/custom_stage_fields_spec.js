import { GlDropdown, GlFormInput } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CustomStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/custom_stage_fields.vue';
import StageFieldActions from 'ee/analytics/cycle_analytics/components/create_value_stream_form/stage_field_actions.vue';
import LabelsSelector from 'ee/analytics/cycle_analytics/components/labels_selector.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import {
  customStageEvents as stageEvents,
  labelStartEvent,
  labelEndEvent,
  customStageEndEvents as endEvents,
} from '../../mock_data';
import { emptyState, emptyErrorsState, firstLabel } from './mock_data';

const formatStartEventOpts = (_events) => [
  { text: 'Select start event', value: null },
  ..._events
    .filter((ev) => ev.canBeStartEvent)
    .map(({ name: text, identifier: value }) => ({ text, value })),
];

const formatEndEventOpts = (_events) => [
  { text: 'Select end event', value: null },
  ..._events
    .filter((ev) => !ev.canBeStartEvent)
    .map(({ name: text, identifier: value }) => ({ text, value })),
];

const startEventOptions = formatStartEventOpts(stageEvents);
const endEventOptions = formatEndEventOpts(stageEvents);

describe('CustomStageFields', () => {
  function createComponent({
    stage = emptyState,
    errors = emptyErrorsState,
    stubs = {},
    props = {},
  } = {}) {
    return extendedWrapper(
      shallowMount(CustomStageFields, {
        propsData: {
          stage,
          errors,
          stageEvents,
          index: 0,
          totalStages: 3,
          ...props,
        },
        stubs: {
          'labels-selector': false,
          ...stubs,
        },
      }),
    );
  }

  let wrapper = null;

  const getDropdown = (dropdownEl) => dropdownEl.findComponent(GlDropdown);
  const getLabelSelect = (dropdownEl) => dropdownEl.findComponent(LabelsSelector);

  const findName = (index = 0) => wrapper.findByTestId(`custom-stage-name-${index}`);
  const findStartEvent = (index = 0) => wrapper.findByTestId(`custom-stage-start-event-${index}`);
  const findEndEvent = (index = 0) => wrapper.findByTestId(`custom-stage-end-event-${index}`);
  const findStartEventLabel = (index = 0) =>
    wrapper.findByTestId(`custom-stage-start-event-label-${index}`);
  const findEndEventLabel = (index = 0) =>
    wrapper.findByTestId(`custom-stage-end-event-label-${index}`);
  const findNameField = () => findName().findComponent(GlFormInput);
  const findStartEventField = () => getDropdown(findStartEvent());
  const findEndEventField = () => getDropdown(findEndEvent());
  const findStartEventLabelField = () => getLabelSelect(findStartEventLabel());
  const findEndEventLabelField = () => getLabelSelect(findEndEventLabel());
  const findStageFieldActions = () => wrapper.findComponent(StageFieldActions);

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
      const $el = finder();
      expect($el.exists()).toBe(true);
      expect($el.attributes('disabled')).toBe(fieldDisabledValue);
    });
  });

  describe.each([
    ['Start event label', findStartEventLabel],
    ['End event label', findEndEventLabel],
  ])('Default state', (field, finder) => {
    it(`field '${field}' is hidden by default`, () => {
      expect(finder().exists()).toBe(false);
    });
  });

  describe('Fields', () => {
    it('emit input event when a field is changed', () => {
      expect(wrapper.emitted('input')).toBeUndefined();
      findNameField().vm.$emit('input', 'Cool new stage');

      expect(wrapper.emitted('input')[0]).toEqual([{ field: 'name', value: 'Cool new stage' }]);
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
          stage: {
            startEventIdentifier: labelStartEvent.identifier,
          },
        });
      });

      it('will display the start event label field if a label event is selected', () => {
        expect(findStartEventLabel().exists()).toEqual(true);
      });

      it('will emit the `input` event when the start event label field when selected', async () => {
        expect(wrapper.emitted('input')).toBeUndefined();

        findStartEventLabelField().vm.$emit('select-label', firstLabel.id);

        expect(wrapper.emitted('input')[0]).toEqual([
          { field: 'startEventLabelId', value: firstLabel.id },
        ]);
      });
    });
  });

  describe('End event', () => {
    const possibleEndEvents = endEvents.filter((ev) =>
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
          stage: {
            startEventIdentifier: labelStartEvent.identifier,
            endEventIdentifier: labelEndEvent.identifier,
          },
        });
      });

      it('will display the end event label field if a label event is selected', () => {
        expect(findEndEventLabel().exists()).toEqual(true);
      });

      it('will emit the `input` event when the start event label field when selected', async () => {
        expect(wrapper.emitted('input')).toBeUndefined();

        findEndEventLabelField().vm.$emit('select-label', firstLabel.id);

        expect(wrapper.emitted('input')[0]).toEqual([
          { field: 'endEventLabelId', value: firstLabel.id },
        ]);
      });
    });
  });

  describe('Stage actions', () => {
    it('will display the stage actions component', () => {
      expect(findStageFieldActions().exists()).toBe(true);
    });

    describe('with only 1 stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ props: { totalStages: 1 } });
      });

      it('does not display the stage actions component', () => {
        expect(findStageFieldActions().exists()).toBe(false);
      });
    });
  });
});
