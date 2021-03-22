import { GlFormGroup, GlFormInput, GlFormText } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DefaultStageFields from 'ee/analytics/cycle_analytics/components/create_value_stream_form/default_stage_fields.vue';
import StageFieldActions from 'ee/analytics/cycle_analytics/components/create_value_stream_form/stage_field_actions.vue';
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
  startEventIdentifier: ISSUE_CREATED.id,
  endEventIdentifier: ISSUE_CLOSED.id,
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
  const findStageFieldNameInput = () => findStageFieldName().find(GlFormInput);
  const findStartEvent = () => wrapper.find('[data-testid="stage-start-event-0"]');
  const findStartEventInput = () => findStartEvent().find(GlFormText);
  const findEndEvent = () => wrapper.find('[data-testid="stage-end-event-0"]');
  const findEndEventInput = () => findEndEvent().find(GlFormText);
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
    expect(findStageFieldNameInput().exists()).toBe(true);
    expect(findStageFieldNameInput().html()).toContain(defaultStage.name);
  });

  it('disables input for the stage field name', () => {
    expect(findStageFieldNameInput().attributes('disabled')).toBe('disabled');
  });

  it('renders the field start event', () => {
    expect(findStartEventInput().exists()).toBe(true);
    expect(findStartEventInput().text()).toBe(ISSUE_CREATED.name);
  });

  it('renders the field end event', () => {
    expect(findEndEventInput().text()).toBe(ISSUE_CLOSED.name);
  });

  it('does not emits any input', () => {
    expect(wrapper.emitted('input')).toBeUndefined();

    const newInput = 'coooool';
    findStageFieldName().vm.$emit('input', newInput);
    expect(wrapper.emitted('input')).toBeUndefined();
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
      expect(findFormGroup().attributes('invalid-feedback')).toBe(stageNameError);
    });
  });
});
