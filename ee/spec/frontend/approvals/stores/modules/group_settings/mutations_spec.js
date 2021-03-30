import mutations from 'ee/approvals/stores/modules/group_settings/mutations';
import getInitialState from 'ee/approvals/stores/modules/group_settings/state';

describe('Group settings store mutations', () => {
  let state;

  beforeEach(() => {
    state = getInitialState();
  });

  describe('REQUEST_SETTINGS', () => {
    it('sets loading state', () => {
      mutations.REQUEST_SETTINGS(state);

      expect(state.isLoading).toBe(true);
    });
  });

  describe('RECEIVE_SETTINGS_SUCCESS', () => {
    it('updates settings', () => {
      mutations.RECEIVE_SETTINGS_SUCCESS(state, {
        allow_author_approval: true,
        require_password_to_approve: true,
        retain_approvals_on_push: true,
      });

      expect(state.settings.preventAuthorApproval).toBe(false);
      expect(state.settings.requireUserPassword).toBe(true);
      expect(state.settings.removeApprovalsOnPush).toBe(false);
      expect(state.isLoading).toBe(false);
    });
  });

  describe('RECEIVE_SETTINGS_ERROR', () => {
    it('sets loading state', () => {
      mutations.RECEIVE_SETTINGS_ERROR(state);

      expect(state.isLoading).toBe(false);
    });
  });

  describe('REQUEST_UPDATE_SETTINGS', () => {
    it('sets loading state', () => {
      mutations.REQUEST_UPDATE_SETTINGS(state);

      expect(state.isLoading).toBe(true);
    });
  });

  describe('UPDATE_SETTINGS_SUCCESS', () => {
    it('updates settings', () => {
      mutations.UPDATE_SETTINGS_SUCCESS(state, {
        allow_author_approval: true,
        require_password_to_approve: true,
        retain_approvals_on_push: true,
      });

      expect(state.settings.preventAuthorApproval).toBe(false);
      expect(state.settings.requireUserPassword).toBe(true);
      expect(state.settings.removeApprovalsOnPush).toBe(false);
      expect(state.isLoading).toBe(false);
    });
  });

  describe('UPDATE_SETTINGS_ERROR', () => {
    it('sets loading state', () => {
      mutations.UPDATE_SETTINGS_ERROR(state);

      expect(state.isLoading).toBe(false);
    });
  });
});
