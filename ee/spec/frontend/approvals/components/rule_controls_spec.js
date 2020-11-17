import { GlButton, GlIcon } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import RuleControls from 'ee/approvals/components/rule_controls.vue';
import { createStoreOptions } from 'ee/approvals/stores';
import MREditModule from 'ee/approvals/stores/modules/mr_edit';

const localVue = createLocalVue();
localVue.use(Vuex);

const TEST_RULE = { id: 10 };

const findButtonLabel = button => {
  const icon = button.find(GlIcon);
  return icon.exists() ? icon.attributes('aria-label') : button.text();
};
const hasLabel = (button, label) => findButtonLabel(button) === label;

describe('EE Approvals RuleControls', () => {
  let wrapper;
  let store;
  let actions;

  const factory = () => {
    wrapper = shallowMount(localVue.extend(RuleControls), {
      propsData: {
        rule: TEST_RULE,
      },
      localVue,
      store: new Vuex.Store(store),
    });
  };
  const findButtons = () => wrapper.findAll(GlButton);
  const findButton = label => findButtons().filter(button => hasLabel(button, label)).wrappers[0];
  const findEditButton = () => findButton('Edit');
  const findRemoveButton = () => findButton('Remove');

  beforeEach(() => {
    store = createStoreOptions(MREditModule());
    ({ actions } = store.modules.approvals);
    ['requestEditRule', 'requestDeleteRule'].forEach(actionName => jest.spyOn(actions, actionName));
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when allow multi rule', () => {
    beforeEach(() => {
      store.state.settings.allowMultiRule = true;
    });

    describe('edit button', () => {
      let button;

      beforeEach(() => {
        factory();
        button = findEditButton();
      });

      it('exists', () => {
        expect(button.exists()).toBe(true);
      });

      it('when click, opens create modal', () => {
        expect(store.modules.approvals.actions.requestEditRule).not.toHaveBeenCalled();

        button.vm.$emit('click');

        expect(store.modules.approvals.actions.requestEditRule).toHaveBeenCalledWith(
          expect.anything(),
          TEST_RULE,
        );
      });
    });

    describe('remove button', () => {
      let button;

      beforeEach(() => {
        factory();
        button = findRemoveButton();
      });

      it('exists', () => {
        expect(button.exists()).toBe(true);
      });

      it('when click, opens delete modal', () => {
        expect(store.modules.approvals.actions.requestDeleteRule).not.toHaveBeenCalled();

        button.vm.$emit('click');

        expect(store.modules.approvals.actions.requestDeleteRule).toHaveBeenCalledWith(
          expect.anything(),
          TEST_RULE,
        );
      });
    });
  });

  describe('when allow only single rule', () => {
    beforeEach(() => {
      factory();
    });

    it('renders edit button', () => {
      expect(findEditButton().exists()).toBe(true);
    });

    it('does remove button', () => {
      expect(findRemoveButton().exists()).toBe(true);
    });
  });
});
