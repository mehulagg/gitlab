import { redirectUserWithSSOIdentity } from 'ee/saml_sso';
import initConfirmDangerModal from '~/confirm_danger_modal';
import UsernameValidator from '~/pages/sessions/new/username_validator';

new UsernameValidator(); // eslint-disable-line no-new
initConfirmDangerModal();
redirectUserWithSSOIdentity();
