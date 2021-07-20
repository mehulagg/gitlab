import '~/boards/models/list';
import { GlFormInput } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { noop } from 'lodash';
import Vuex from 'vuex';
import BoardSettingsWipLimit from 'ee_component/boards/components/board_settings_wip_limit.vue';
import waitForPromises from 'helpers/wait_for_promises';
import boardsStore from '~/boards/stores/boards_store';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('BoardSettingsWipLimit', () => {
  let wrapper;
  let storeActions;
  const labelTitle = 'test';
  const labelColor = '#FFFF';
  const listId = 1;
  const currentWipLimit = 1; // Needs to be other than null to trigger requests
  let mock;

  const addList = (maxIssueCount = 0) => {
    boardsStore.addList({
      id: listId,
      label: { title: labelTitle, color: labelColor },
      max_issue_count: maxIssueCount,
      list_type: 'label',
    });
  };
  const clickEdit = () => wrapper.find('.js-edit-button').vm.$emit('click');
  const findRemoveWipLimit = () => wrapper.find('.js-remove-limit');
  const findWipLimit = () => wrapper.find('.js-wip-limit');
  const findInput = () => wrapper.find(GlFormInput);

  const createComponent = ({
    vuexState = { activeId: listId },
    actions = {},
    localState = {},
    props = { maxIssueCount: 0 },
  }) => {
    storeActions = actions;

    const store = new Vuex.Store({
      state: vuexState,
      actions: storeActions,
      getters: { shouldUseGraphQL: () => false },
    });

    wrapper = shallowMount(BoardSettingsWipLimit, {
      propsData: props,
      store,
      localVue,
      data() {
        return localState;
      },
    });
  };

  const triggerBlur = (type) => {
    if (type === 'blur') {
      findInput().vm.$emit('blur');
    }

    if (type === 'enter') {
      findInput().trigger('keydown.enter');
    }
  };

  beforeEach(() => {
    boardsStore.create();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    jest.restoreAllMocks();
    wrapper.destroy();
  });

  describe('when activeList is present', () => {
    describe('when activeListWipLimit is 0', () => {
      it('renders "None" in the block', () => {
        createComponent({ vuexState: { activeId: listId } });

        expect(findWipLimit().text()).toBe('None');
      });
    });

    describe('when activeId is greater than 0', () => {
      afterEach(() => {
        boardsStore.removeList(listId);
      });

      it.each`
        num   | expected
        ${1}  | ${'1 issue'}
        ${11} | ${'11 issues'}
      `('it renders $num', ({ num, expected }) => {
        addList(4);

        createComponent({ vuexState: { activeId: num }, props: { maxIssueCount: num } });

        expect(findWipLimit().text()).toBe(expected);
      });
    });
  });

  describe('when clicking edit', () => {
    const maxIssueCount = 4;
    beforeEach(async () => {
      createComponent({
        vuexState: { activeId: listId },
        actions: { updateListWipLimit: noop },
        props: { maxIssueCount },
      });

      clickEdit();

      await wrapper.vm.$nextTick();
    });

    it('renders an input', () => {
      expect(findInput().exists()).toBe(true);
    });

    it('does not render current wipLimit text', () => {
      expect(findWipLimit().exists()).toBe(false);
    });

    it('sets wipLimit to be the value of list.maxIssueCount', () => {
      expect(findInput().attributes('value')).toBe(String(maxIssueCount));
    });
  });

  describe('remove limit', () => {
    describe('when wipLimit is set', () => {
      beforeEach(() => {
        addList(4);

        const spy = jest.fn().mockResolvedValue({
          config: { data: JSON.stringify({ list: { max_issue_count: 0 } }) },
        });

        createComponent({
          vuexState: { activeId: listId },
          actions: { updateListWipLimit: spy },
          props: { maxIssueCount: 4 },
        });
      });

      it('resets wipLimit to 0', async () => {
        expect(findWipLimit().text()).toContain(4);

        findRemoveWipLimit().vm.$emit('click');

        await wrapper.vm.$nextTick();

        // WARNING: https://gitlab.com/gitlab-org/gitlab/-/issues/232573
        expect(boardsStore.findList('id', listId).maxIssueCount).toBe(0);
      });
    });

    describe('when wipLimit is not set', () => {
      beforeEach(() => {
        addList();

        createComponent({ vuexState: { activeId: listId }, actions: { updateListWipLimit: noop } });
      });

      it('does not render the remove limit button', () => {
        expect(findRemoveWipLimit().exists()).toBe(false);
      });
    });
  });

  describe('when edit is true', () => {
    beforeEach(() => {
      addList(2);
    });

    afterEach(() => {
      boardsStore.removeList(listId);
    });

    describe.each`
      blurMethod
      ${'enter'}
      ${'blur'}
    `('$blurMethod', ({ blurMethod }) => {
      describe(`when blur is triggered by ${blurMethod}`, () => {
        it('calls updateListWipLimit', async () => {
          const spy = jest.fn().mockResolvedValue({
            config: { data: JSON.stringify({ list: { max_issue_count: '4' } }) },
          });
          createComponent({
            vuexState: { activeId: listId },
            actions: { updateListWipLimit: spy },
            localState: { edit: true, currentWipLimit },
          });

          triggerBlur(blurMethod);

          await wrapper.vm.$nextTick();

          expect(spy).toHaveBeenCalledTimes(1);
        });

        describe('when component wipLimit and List.maxIssueCount are equal', () => {
          it('doesnt call updateListWipLimit', async () => {
            const spy = jest.fn().mockResolvedValue({});
            createComponent({
              vuexState: { activeId: listId },
              actions: { updateListWipLimit: spy },
              localState: { edit: true, currentWipLimit: 2 },
              props: { maxIssueCount: 2 },
            });

            triggerBlur(blurMethod);

            await wrapper.vm.$nextTick();

            expect(spy).toHaveBeenCalledTimes(0);
          });
        });

        describe('when currentWipLimit is null', () => {
          it('doesnt call updateListWipLimit', async () => {
            const spy = jest.fn().mockResolvedValue({});
            createComponent({
              vuexState: { activeId: listId },
              actions: { updateListWipLimit: spy },
              localState: { edit: true, currentWipLimit: null },
            });

            triggerBlur(blurMethod);

            await wrapper.vm.$nextTick();

            expect(spy).toHaveBeenCalledTimes(0);
          });
        });

        describe('when response is successful', () => {
          const maxIssueCount = 11;

          beforeEach(() => {
            const spy = jest.fn().mockResolvedValue({});
            createComponent({
              vuexState: { activeId: listId },
              actions: { updateListWipLimit: spy },
              localState: { edit: true, currentWipLimit: maxIssueCount },
            });

            triggerBlur(blurMethod);

            return waitForPromises();
          });

          it('sets activeWipLimit to new maxIssueCount value', () => {
            /*
             * DANGER: bad coupling to the computed prop of the component because the
             * computed prop relys on the list from boardStore, for now this is the way around
             * stale values from boardsStore being updated, when we move List and BoardsStore to Vuex
             * or Graphql we will be able to query the DOM for the new value.
             */

            expect(boardsStore.findList('id', 1).maxIssueCount).toBe(maxIssueCount);
          });

          it('toggles GlFormInput on blur', () => {
            expect(findInput().exists()).toBe(false);
            expect(findWipLimit().exists()).toBe(true);
            expect(wrapper.vm.updating).toBe(false);
          });
        });

        describe('when response fails', () => {
          beforeEach(() => {
            const spy = jest.fn().mockRejectedValue();
            createComponent({
              vuexState: { activeId: listId },
              actions: { updateListWipLimit: spy, unsetActiveId: noop },
              localState: { edit: true, currentWipLimit },
            });
            jest.spyOn(wrapper.vm, 'setError').mockImplementation(() => {});

            triggerBlur(blurMethod);

            return waitForPromises();
          });

          it('calls flash with expected error', () => {
            expect(wrapper.vm.setError).toHaveBeenCalledTimes(1);
          });
        });
      });
    });

    describe('passing of props to gl-form-input', () => {
      beforeEach(() => {
        createComponent({
          vuexState: { activeId: listId },
          actions: { updateListWipLimit: noop },
          localState: { edit: true },
        });
      });

      it('passes `trim`', () => {
        expect(findInput().attributes().trim).toBeDefined();
      });

      it('passes `number`', () => {
        expect(findInput().attributes().number).toBeDefined();
      });
    });
  });
});
