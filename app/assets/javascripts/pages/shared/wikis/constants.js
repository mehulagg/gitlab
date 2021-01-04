import { s__ } from '~/locale';

export const ERRORS = {
  PAGE_CHANGE: {
    ERROR: 'WikiPage::PageChangedError',
    MESSAGE: s__(
      'WikiPageConflictMessage|Someone edited the page the same time you did. Please check out %{wikiLinkStart}the page%{wikiLinkEnd} and make sure your changes will not unintentionally remove theirs.',
    ),
  },
  PAGE_RENAME: {
    ERROR: 'WikiPage::PageRenameError',
    MESSAGE: s__('WikiEdit|There is already a page with the same title in that path.'),
  },
};
