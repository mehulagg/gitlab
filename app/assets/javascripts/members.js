import { disableButtonIfEmptyField } from '~/lib/utils/common_utils';

export const initInviteMembersForm = () => {
  disableButtonIfEmptyField('#user_ids', 'input[name=commit]', 'change');
};
