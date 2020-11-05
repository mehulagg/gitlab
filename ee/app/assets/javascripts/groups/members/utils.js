import { parseDataAttributes as CEParseDataAttributes } from '~/groups/members/utils';

export const parseDataAttributes = el => {
  const { ldapOverridePath } = el.dataset;

  return {
    ...CEParseDataAttributes(el),
    ldapOverridePath,
  };
};
