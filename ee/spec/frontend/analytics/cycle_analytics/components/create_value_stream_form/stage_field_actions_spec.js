import { shallowMount } from '@vue/test-utils';
import StageFieldActions from 'ee/analytics/cycle_analytics/components/create_value_stream_form/stage_field_actions.vue';

const defaultIndex = 0;
const stageCount = 3;

describe('StageFieldActions', () => {
  function createComponent({ index = defaultIndex }) {
    return shallowMount(StageFieldActions, {
      propsData: {
        index,
        stageCount,
      },
    });
  }

  let wrapper = null;
  const findMoveDownBtn = () => wrapper.find('[data-testid^="stage-action-move-down"]');
  const findMoveUpBtn = () => wrapper.find('[data-testid^="stage-action-move-up"]');
  const findHideBtn = () => wrapper.find('[data-testid^="stage-action-hide"]');

  beforeEach(() => {
    wrapper = createComponent({});
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('will render the move up action', () => {
    expect(findMoveUpBtn().exists()).toBe(true);
  });

  it('will render the move down action', () => {
    expect(findMoveDownBtn().exists()).toBe(true);
  });

  it('will render the hide action', () => {
    expect(findHideBtn().exists()).toBe(true);
  });

  it('disables the move up button', () => {
    expect(findMoveUpBtn().props('disabled')).toBe(true);
  });

  it('when the down button is clicked will emit a `move` event', () => {
    findMoveDownBtn().vm.$emit('click');
    expect(wrapper.emitted('move')[0]).toEqual([{ direction: 'DOWN', index: 0 }]);
  });

  it('when the up button is clicked will emit a `move` event', () => {
    findMoveUpBtn().vm.$emit('click');
    expect(wrapper.emitted('move')[0]).toEqual([{ direction: 'UP', index: 0 }]);
  });

  it('when the hide button is clicked will emit a `move` event', () => {
    findHideBtn().vm.$emit('click');
    expect(wrapper.emitted('hide')[0]).toEqual([0]);
  });

  describe('when the current index is the same as the total number of stages', () => {
    beforeEach(() => {
      wrapper = createComponent({ index: 2 });
    });

    it('disables the move down button', () => {
      expect(findMoveDownBtn().props('disabled')).toBe(true);
    });
  });
});
