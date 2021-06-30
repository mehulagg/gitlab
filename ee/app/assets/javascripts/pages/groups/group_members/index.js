import '~/pages/groups/group_members';
import initConfirmModal from '~/confirm_modal';

const LDAP_SYNC_NOW_BUTTON_SELECTOR = '.js-ldap-sync-now-button';
if (document.querySelector(LDAP_SYNC_NOW_BUTTON_SELECTOR)) {
  initConfirmModal({ selector: LDAP_SYNC_NOW_BUTTON_SELECTOR });
}
