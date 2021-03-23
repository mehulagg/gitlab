import { GlButton, GlForm, GlLink, GlIcon } from '@gitlab/ui';
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
      stubs: {
        GlLink,
      },
    });
  };

  const findForm = () => wrapper.findComponent(GlForm);
  const findPreventAuthorApproval = () => wrapper.find('[data-testid="prevent-author-approval"]');
  const findRequireUserPassword = () => wrapper.find('[data-testid="require-user-password"]');
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

  describe('checkboxes', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('shows all the checkboxes', () => {
      expect(
        [findPreventAuthorApproval().exists(), findRequireUserPassword().exists()].every((x) => x),
      ).toBe(true);
    });

    it('shows the checkbox label', () => {
      expect(findPreventAuthorApproval().text()).toBe('Prevent MR approvals by the author.');
    });

    it('shows the help link', () => {
      const link = findRequireUserPassword().find(GlLink);

      expect(link.attributes('href')).toBe(
        '/help/user/project/merge_requests/merge_request_approvals#require-authentication-when-approving-a-merge-request',
      );
      expect(link.find(GlIcon).props('name')).toBe('question-o');
    });
  });

  describe('interact with checkboxes', () => {
    it.each`
      find                         | setting
      ${findPreventAuthorApproval} | ${'preventAuthorApproval'}
      ${findRequireUserPassword}   | ${'requireUserPassword'}
    `('renders the $setting checkbox with correct value', async ({ find, setting }) => {
      createWrapper();

      await find().vm.$emit('input', true);

      expect(store.modules.approvals.state.settings[setting]).toBe(true);
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
