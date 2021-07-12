/* global DocumentTouch */

import sortableConfig from '~/sortable/sortable_config';
import { NO_DRAG_CLASS } from '../constants';

export default () => {
  const touchEnabled =
    'ontouchstart' in window || (window.DocumentTouch && document instanceof DocumentTouch);

  return {
    ...sortableConfig,
    fallbackOnBody: false,
    group: {
      name: 'stages',
    },
    dataIdAttr: 'data-id',
    dragClass: 'sortable-drag',
    filter: `.${NO_DRAG_CLASS}`,
    delay: touchEnabled ? 100 : 0,
    scrollSensitivity: touchEnabled ? 60 : 100,
    scrollSpeed: 20,
    fallbackTolerance: 1,
    onMove(e) {
      return !e.related.classList.contains(NO_DRAG_CLASS);
    },
  };
};
