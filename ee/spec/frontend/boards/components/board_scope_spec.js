import { createLocalVue, mount } from '@vue/test-utils';
import Vuex from 'vuex';
import BoardScope from 'ee/boards/components/board_scope.vue';
import { TEST_HOST } from 'helpers/test_constants';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('BoardScope', () => {
  let wrapper;
  let vm;

  beforeEach(() => {
    const propsData = {
      collapseScope: false,
      canAdminBoard: false,
      board: {
        labels: [],
        assignee: {},
      },
      labelsPath: `${TEST_HOST}/labels`,
      labelsWebUrl: `${TEST_HOST}/-/labels`,
    };

    const createStore = () => {
      return new Vuex.Store({
        getters: {
          isIssueBoard: () => true,
          isEpicBoard: () => false,
        },
      });
    };

    const store = createStore();

    wrapper = mount(BoardScope, {
      localVue,
      propsData,
      store,
    });

    ({ vm } = wrapper);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('handleLabelClick', () => {
      const label = {
        id: 1,
        title: 'Foo',
        color: ['#BADA55'],
        text_color: '#FFFFFF',
      };

      it('adds provided `label` to board.labels', () => {
        vm.handleLabelClick([label]);

        expect(vm.board.labels).toHaveLength(1);
        expect(vm.board.labels[0].id).toBe(label.id);
      });
    });
  });
});
