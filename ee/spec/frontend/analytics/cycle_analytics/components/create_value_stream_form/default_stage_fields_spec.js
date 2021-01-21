import { shallowMount } from '@vue/test-utils';
import { GlFormGroup } from '@gitlab/ui';
import StageFieldActions from 'ee/analytics/cycle_analytics/components/create_value_stream_form/stage_field_actions.vue';
import DefaultStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/default_stage_fields.vue';
import { customStageEvents as stageEvents } from '../../mock_data';

let wrapper = null;

const defaultStageIndex = 0;
const totalStages = 5;
const stageNameError = 'Name is required';
const defaultErrors = { name: [stageNameError] };
const ISSUE_CREATED = { id: 'issue_created', name: 'Issue created' };
const ISSUE_CLOSED = { id: 'issue_closed', name: 'Issue closed' };
const defaultStage = {
  name: 'Cool new stage',
  startEventIdentifier: [ISSUE_CREATED.id],
  endEventIdentifier: [ISSUE_CLOSED.id],
  endEventLabel: 'some_label',
};

describe('DefaultStageFields', () => {
  function createComponent({ stage = defaultStage, errors = {} } = {}) {
    return shallowMount(DefaultStageFields, {
      propsData: {
        index: defaultStageIndex,
        totalStages,
        stage,
        errors,
        stageEvents,
      },
      stubs: {
        'labels-selector': false,
        'gl-form-text': false,
      },
    });
  }

  const findStageFieldName = () => wrapper.find('[name="create-value-stream-stage-0"]');
  const findStartEvent = () => wrapper.find('[data-testid="stage-start-event-0"]');
  const findEndEvent = () => wrapper.find('[data-testid="stage-end-event-0"]');
  const findFormGroup = () => wrapper.find(GlFormGroup);
  const findFieldActions = () => wrapper.find(StageFieldActions);

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders the stage field name', () => {
    expect(findStageFieldName().exists()).toBe(true);
    expect(findStageFieldName().html()).toContain(defaultStage.name);
  });

  it('renders the field start event', () => {
    expect(findStartEvent().exists()).toBe(true);
    expect(findStartEvent().html()).toContain(ISSUE_CREATED.name);
  });

  it('renders the field end event', () => {
    const content = findEndEvent().html();
    expect(content).toContain(ISSUE_CLOSED.name);
    expect(content).toContain(defaultStage.endEventLabel);
  });

  it('renders an event label if it exists', () => {
    const content = findEndEvent().html();
    expect(content).toContain(defaultStage.endEventLabel);
  });

  it('on field input emits an input event', () => {
    expect(wrapper.emitted('input')).toBeUndefined();

    const newInput = 'coooool';
    findStageFieldName().vm.$emit('input', newInput);
    expect(wrapper.emitted('input')[0]).toEqual([newInput]);
  });

  describe('StageFieldActions', () => {
    it('when the stage is hidden emits a `hide` event', () => {
      expect(wrapper.emitted('hide')).toBeUndefined();

      const stageMoveParams = { index: defaultStageIndex, direction: 'UP' };
      findFieldActions().vm.$emit('move', stageMoveParams);
      expect(wrapper.emitted('move')[0]).toEqual([stageMoveParams]);
    });

    it('when the stage is moved emits a `move` event', () => {
      expect(wrapper.emitted('move')).toBeUndefined();

      findFieldActions().vm.$emit('move', defaultStageIndex);
      expect(wrapper.emitted('move')[0]).toEqual([defaultStageIndex]);
    });
  });

  describe('with field errors', () => {
    beforeEach(() => {
      wrapper = createComponent({ errors: defaultErrors });
    });

    it('displays the field error', () => {
      expect(findFormGroup().html()).toContain(stageNameError);
    });
  });
});
