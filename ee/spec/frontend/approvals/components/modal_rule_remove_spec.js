import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import ModalRuleRemove from 'ee/approvals/components/modal_rule_remove.vue';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';

const MODAL_MODULE = 'deleteModal';
const TEST_MODAL_ID = 'test-delete-modal-id';
const TEST_RULE = {
  id: 7,
  name: 'Lorem',
  approvers: Array(5)
    .fill(1)
    .map((x, id) => ({ id })),
};

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Approvals ModalRuleRemove', () => {
  let wrapper;
  let actions;
  let deleteModalState;

  const factory = (options = {}) => {
    const store = new Vuex.Store({
      actions,
      modules: {
        [MODAL_MODULE]: {
          namespaced: true,
          state: deleteModalState,
        },
      },
    });

    const propsData = {
      modalId: TEST_MODAL_ID,
      ...options.propsData,
    };

    wrapper = shallowMount(ModalRuleRemove, {
      ...options,
      localVue,
      store,
      propsData,
    });
  };

  beforeEach(() => {
    deleteModalState = {
      data: TEST_RULE,
    };
    actions = {
      deleteRule: jest.fn(),
    };
  });

  it('renders modal', () => {
    factory();

    const modal = wrapper.find(GlModalVuex);

    expect(modal.exists()).toBe(true);
    expect(modal.props()).toEqual(
      expect.objectContaining({
        modalModule: MODAL_MODULE,
        modalId: TEST_MODAL_ID,
      }),
    );
  });

  it('shows message', () => {
    factory();

    const modal = wrapper.find(GlModalVuex);

    expect(modal.text()).toContain(TEST_RULE.name);
    expect(modal.text()).toContain(`${TEST_RULE.approvers.length} members`);
  });

  it('shows singular message', () => {
    deleteModalState.data = {
      ...TEST_RULE,
      approvers: [{ id: 1 }],
    };
    factory();

    const modal = wrapper.find(GlModalVuex);

    expect(modal.text()).toContain('1 member');
  });

  it('deletes rule when modal is submitted', () => {
    factory();

    expect(actions.deleteRule).not.toHaveBeenCalled();

    const modal = wrapper.find(GlModalVuex);
    modal.vm.$emit('ok', new Event('submit'));

    expect(actions.deleteRule).toHaveBeenCalledWith(expect.anything(), TEST_RULE.id);
  });
});
