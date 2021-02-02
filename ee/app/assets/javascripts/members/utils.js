import { __ } from '~/locale';
import {
  generateBadges as CEGenerateBadges,
  parseDataAttributes as CEParseDataAttributes,
  isDirectMember,
} from '~/members/utils';

export {
  isGroup,
  isDirectMember,
  isCurrentUser,
  canRemove,
  canResend,
  canUpdate,
} from '~/members/utils';

export const generateBadges = (member, isCurrentUser) => [
  ...CEGenerateBadges(member, isCurrentUser),
  {
    show: member.usingLicense,
    text: __('Is using seat'),
    variant: 'neutral',
  },
  {
    show: member.groupSso,
    text: __('SAML'),
    variant: 'info',
  },
  {
    show: member.groupManagedAccount,
    text: __('Managed Account'),
    variant: 'info',
  },
  {
    show: member.canOverride,
    text: __('LDAP'),
    variant: 'info',
  },
];

export const canOverride = (member) => member.canOverride && isDirectMember(member);

export const parseDataAttributes = (el) => {
  const { ldapOverridePath } = el.dataset;

  return {
    ...CEParseDataAttributes(el),
    ldapOverridePath,
  };
};
