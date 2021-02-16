import { GlButton, GlForm } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';

import ApprovalSettings from 'ee/approvals/components/approval_settings.vue';
import { createStoreOptions } from 'ee/approvals/stores';
import groupSettingsModule from 'ee/approvals/stores/modules/group_settings';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ApprovalSettings', () => {
  let wrapper;
  let store;
  let actions;

  const approvalSettingsPath = 'groups/22/merge_request_approval_settings';

  const createWrapper = () => {
    wrapper = shallowMount(ApprovalSettings, {
      localVue,
      store: new Vuex.Store(store),
      propsData: { approvalSettingsPath },
    });
  };

  const findForm = () => wrapper.findComponent(GlForm);
  const findPreventAuthorApproval = () => wrapper.find('[data-testid="prevent-author-approval"]');
  const findSaveButton = () => wrapper.findComponent(GlButton);

  beforeEach(() => {
    store = createStoreOptions(groupSettingsModule());

    jest.spyOn(store.modules.approvals.actions, 'fetchSettings').mockImplementation();
    jest.spyOn(store.modules.approvals.actions, 'updateSettings').mockImplementation();
    ({ actions } = store.modules.approvals);
  });

  afterEach(() => {
    wrapper.destroy();
    store = null;
  });

  it('fetches settings from API', () => {
    createWrapper();

    expect(actions.fetchSettings).toHaveBeenCalledWith(expect.any(Object), approvalSettingsPath);
  });

  describe('interact with checkboxes', () => {
    it('renders checkbox with correct value', async () => {
      createWrapper();

      const input = findPreventAuthorApproval();
      await input.vm.$emit('input', false);

      expect(store.modules.approvals.state.settings.preventAuthorApproval).toBe(false);
    });
  });

  describe('loading', () => {
    it('renders enabled button when not loading', () => {
      store.modules.approvals.state.isLoading = false;

      createWrapper();

      expect(findSaveButton().props('disabled')).toBe(false);
    });

    it('renders disabled button when loading', () => {
      store.modules.approvals.state.isLoading = true;

      createWrapper();

      expect(findSaveButton().props('disabled')).toBe(true);
    });
  });

  describe('form submission', () => {
    it('update settings via API', async () => {
      createWrapper();

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(actions.updateSettings).toHaveBeenCalledWith(expect.any(Object), approvalSettingsPath);
    });
  });
});
