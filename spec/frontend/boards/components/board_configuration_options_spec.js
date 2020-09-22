import { shallowMount } from '@vue/test-utils';
import { GlFormCheckbox } from '@gitlab/ui';
import BoardConfigurationOptions from '~/boards/components/board_configuration_options.vue';

describe('BoardConfigurationOptions', () => {
  let wrapper;
  const board = { hide_backlog_list: false, hide_closed_list: false };

  const defaultProps = {
    currentBoard: board,
    board,
    isNewForm: false,
  };

  const createComponent = () => {
    wrapper = shallowMount(BoardConfigurationOptions, {
      propsData: { ...defaultProps },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const checkboxAssert = (backlogCheckbox, closedCheckbox) => {
    const checkboxes = wrapper.findAll(GlFormCheckbox);
    expect(checkboxes.at(0).attributes('checked')).toEqual(backlogCheckbox);
    expect(checkboxes.at(1).attributes('checked')).toEqual(closedCheckbox);
  };

  it('renders two checkboxes checked by default', () => {
    const checkboxes = wrapper.findAll(GlFormCheckbox);
    expect(checkboxes).toHaveLength(2);

    checkboxAssert('true', 'true');
  });

  it('renders right configuration when editing board', async () => {
    await wrapper.setData({ hideBacklogList: true, hideClosedList: false });

    return wrapper.vm.$nextTick().then(() => {
      checkboxAssert(undefined, 'true');
    });
  });

  it('renders right configuration when creating board', async () => {
    await wrapper.setProps({ isNewForm: true });
    await wrapper.setData({ hideBacklogList: false, hideClosedList: true });

    return wrapper.vm.$nextTick().then(() => {
      checkboxAssert('true', undefined);
    });
  });
});
