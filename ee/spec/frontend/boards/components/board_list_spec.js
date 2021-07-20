import BoardNewEpic from 'ee/boards/components/board_new_epic.vue';
import createComponent from 'jest/boards/board_list_helper';

import BoardCard from '~/boards/components/board_card.vue';
import BoardCardInner from '~/boards/components/board_card_inner.vue';
import { issuableTypes } from '~/boards/constants';
import eventHub from '~/boards/eventhub';
import createFlash from '~/flash';

jest.mock('~/flash');

const listIssueProps = {
  project: {
    path: '/test',
  },
  real_path: '',
  webUrl: '',
};

const componentProps = {
  groupId: undefined,
};

const actions = {
  addListNewEpic: jest.fn().mockResolvedValue(),
};

const componentConfig = {
  listIssueProps,
  componentProps,
  getters: {
    isGroupBoard: () => true,
    isProjectBoard: () => false,
    isEpicBoard: () => true,
  },
  state: {
    issuableType: issuableTypes.epic,
  },
  actions,
  stubs: {
    BoardCard,
    BoardCardInner,
    BoardNewEpic,
  },
  provide: {
    scopedLabelsAvailable: true,
  },
};

describe('BoardList Component', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent(componentConfig);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders link properly in issue', () => {
    expect(wrapper.find('.board-card .board-card-title a').attributes('href')).not.toContain(
      ':project_path',
    );
  });

  describe('board-new-epic component', () => {
    const submitForm = async (w) => {
      const newEpicForm = w.findComponent(BoardNewEpic);

      newEpicForm.find('input').setValue('Foo');
      newEpicForm.find('form').trigger('submit');

      await wrapper.vm.$nextTick();
    };

    beforeEach(async () => {
      eventHub.$emit(`toggle-epic-form-${wrapper.vm.list.id}`);

      await wrapper.vm.$nextTick();
    });

    it('renders component', () => {
      expect(wrapper.findComponent(BoardNewEpic).exists()).toBe(true);
    });

    it('calls action `addListNewEpic` when "Create epic" button is clicked', async () => {
      await submitForm(wrapper);

      expect(actions.addListNewEpic).toHaveBeenCalledWith(
        expect.any(Object),
        expect.objectContaining({
          epicInput: {
            title: 'Foo',
            boardId: 'gid://gitlab/Boards::EpicBoard/',
            listId: 'gid://gitlab/List/1',
          },
        }),
      );
    });

    it('calls `createFlash` when form submission fails', async () => {
      const mockActions = {
        addListNewEpic: jest.fn().mockRejectedValue(),
      };
      wrapper = createComponent({
        ...componentConfig,
        actions: mockActions,
      });

      eventHub.$emit(`toggle-epic-form-${wrapper.vm.list.id}`);

      await wrapper.vm.$nextTick();

      await submitForm(wrapper);

      return mockActions.addListNewEpic().catch((error) => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to create epic. Please try again.',
          captureError: true,
          error,
        });
      });
    });
  });
});
