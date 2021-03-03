import { __, s__ } from '~/locale';

export const DEFAULT_TH_CLASSES =
  'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1!';
const thWidthClass = (width) => `gl-w-${width}p ${DEFAULT_TH_CLASSES}`;

export const FIELDS = [
  {
    key: 'user',
    label: __('User'),
    thClass: thWidthClass(40),
  },
  {
    key: 'email',
    label: __('Email'),
    thClass: thWidthClass(40),
  },
  {
    key: 'lastActivityTime',
    label: __('Last activity'),
    thClass: thWidthClass(40),
  },
  {
    key: 'actions',
    label: '',
    tdClass: 'text-right',
    customStyle: { width: '35px' },
  },
];

export const REMOVE_MEMBER_MODAL_ID = 'member-remove-modal';
export const REMOVE_MEMBER_MODAL_CONTENT_TEXT_TEMPLATE = s__(
  `Billing|You are about to remove user %{username} from your subscription.
If you continue, the user will be removed from the %{namespace}
group and all its subgroups and projects. This action can't be undone.`,
);
export const AVATAR_SIZE = 32;
export const SEARCH_DEBOUNCE_MS = 250;
