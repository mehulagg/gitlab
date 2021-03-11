import { GlAvatarLabeled, GlSearchBoxByType, GlFormSelect } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue, { nextTick } from 'vue';
import Vuex from 'vuex';
import BoardAddNewColumn from 'ee/boards/components/board_add_new_column.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import BoardAddNewColumnForm from '~/boards/components/board_add_new_column_form.vue';
import { ListType } from '~/boards/constants';
import defaultState from '~/boards/stores/state';
import { mockAssignees, mockLists } from '../mock_data';

const mockLabelList = mockLists[1];

Vue.use(Vuex);

describe('BoardAddNewColumn', () => {
  let wrapper;
  let shouldUseGraphQL;

  const createStore = ({ actions = {}, getters = {}, state = {} } = {}) => {
    return new Vuex.Store({
      state: {
        ...defaultState,
        ...state,
      },
      actions,
      getters,
    });
  };

  const mountComponent = ({
    selectedId,
    labels = [],
    assignees = [],
    getListByTypeId = jest.fn(),
    actions = {},
  } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(BoardAddNewColumn, {
        stubs: {
          BoardAddNewColumnForm,
        },
        data() {
          return {
            selectedId,
          };
        },
        store: createStore({
          actions: {
            fetchLabels: jest.fn(),
            setAddColumnFormVisibility: jest.fn(),
            ...actions,
          },
          getters: {
            shouldUseGraphQL: () => shouldUseGraphQL,
            getListByTypeId: () => getListByTypeId,
            isEpicBoard: () => false,
          },
          state: {
            labels,
            labelsLoading: false,
            assignees,
            assigneesLoading: false,
          },
        }),
        provide: {
          scopedLabelsAvailable: true,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findForm = () => wrapper.findComponent(BoardAddNewColumnForm);
  const formTitle = () => wrapper.findByTestId('board-add-column-form-title').text();
  const findSearchInput = () => wrapper.find(GlSearchBoxByType);
  const cancelButton = () => wrapper.findByTestId('cancelAddNewColumn');
  const submitButton = () => wrapper.findByTestId('addNewColumnButton');
  const listTypeSelect = () => wrapper.findComponent(GlFormSelect);

  beforeEach(() => {
    shouldUseGraphQL = true;
  });

  it('shows form title & search input', () => {
    mountComponent();

    expect(formTitle()).toEqual(BoardAddNewColumnForm.i18n.newList);
    expect(findSearchInput().exists()).toBe(true);
  });

  it('clicking cancel hides the form', () => {
    const setAddColumnFormVisibility = jest.fn();
    mountComponent({
      actions: {
        setAddColumnFormVisibility,
      },
    });

    cancelButton().vm.$emit('click');

    expect(setAddColumnFormVisibility).toHaveBeenCalledWith(expect.anything(), false);
  });

  describe('Add list button', () => {
    it('is disabled if no item is selected', () => {
      mountComponent();

      expect(submitButton().props('disabled')).toBe(true);
    });

    it('adds a new list on click', async () => {
      const labelId = mockLabelList.label.id;
      const highlightList = jest.fn();
      const createList = jest.fn();

      mountComponent({
        labels: [mockLabelList.label],
        selectedId: labelId,
        actions: {
          createList,
          highlightList,
        },
      });

      await nextTick();

      submitButton().vm.$emit('click');

      expect(highlightList).not.toHaveBeenCalled();
      expect(createList).toHaveBeenCalledWith(expect.anything(), { labelId });
    });

    it('highlights existing list if trying to re-add', async () => {
      const getListByTypeId = jest.fn().mockReturnValue(mockLabelList);
      const highlightList = jest.fn();
      const createList = jest.fn();

      mountComponent({
        labels: [mockLabelList.label],
        selectedId: mockLabelList.label.id,
        getListByTypeId,
        actions: {
          createList,
          highlightList,
        },
      });

      await nextTick();

      submitButton().vm.$emit('click');

      expect(highlightList).toHaveBeenCalledWith(expect.anything(), mockLabelList.id);
      expect(createList).not.toHaveBeenCalled();
    });
  });

  describe('assignee list', () => {
    beforeEach(async () => {
      mountComponent({
        assignees: mockAssignees,
        actions: {
          fetchAssignees: jest.fn(),
        },
      });

      listTypeSelect().vm.$emit('change', ListType.assignee);

      await nextTick();
    });

    it('sets assignee placeholder text in form', async () => {
      expect(findForm().props()).toMatchObject({
        formDescription: BoardAddNewColumn.i18n.assigneeListDescription,
        searchLabel: BoardAddNewColumn.i18n.selectAssignee,
        searchPlaceholder: BoardAddNewColumn.i18n.searchAssignees,
      });
    });

    it('shows list of assignees', () => {
      const userList = wrapper.findAllComponents(GlAvatarLabeled);

      const [firstUser] = mockAssignees;

      expect(userList).toHaveLength(mockAssignees.length);
      expect(userList.at(0).props()).toMatchObject({
        label: firstUser.name,
        subLabel: firstUser.username,
      });
    });
  });
});
