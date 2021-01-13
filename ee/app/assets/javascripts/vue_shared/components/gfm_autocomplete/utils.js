import { escape } from 'lodash';
import {
  GfmAutocompleteType as GfmAutocompleteTypeFoss,
  tributeConfig as tributeConfigFoss,
} from '~/vue_shared/components/gfm_autocomplete/utils';

export const GfmAutocompleteType = {
  ...GfmAutocompleteTypeFoss,
  Epics: 'epics',
};

export const tributeConfig = {
  ...tributeConfigFoss,

  [GfmAutocompleteType.Epics]: {
    config: {
      trigger: '&',
      fillAttr: 'iid',
      lookup: (value) => `${value.iid}${value.title}`,
      menuItemTemplate: ({ original }) =>
        `<small>${original.iid}</small> ${escape(original.title)}`,
    },
  },
};
