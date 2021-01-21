import { redirectUserWithSSOIdentity } from 'ee/saml_sso';
import UsernameValidator from '~/pages/sessions/new/username_validator';
import initConfirmDangerModal from '~/confirm_danger_modal';

new UsernameValidator(); // eslint-disable-line no-new
initConfirmDangerModal();
redirectUserWithSSOIdentity();
