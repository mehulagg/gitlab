import $ from 'jquery';
import Cookies from 'js-cookie';
import Mousetrap from 'mousetrap';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import { parseBoolean } from '~/lib/utils/common_utils';
import {
  keysFor,
  EPIC_ISSUE_MR_CHANGE_LABEL,
  EPIC_ISSUE_MR_COMMENT_OR_REPLY,
  EPIC_ISSUE_MR_EDIT_DESCRIPTION,
} from '~/behaviors/shortcuts/keybindings';

export default class ShortcutsEpic extends ShortcutsIssuable {
  constructor() {
    super();

    const $issuableSidebar = $('.js-issuable-update');

    Mousetrap.bind(keysFor(EPIC_ISSUE_MR_CHANGE_LABEL), () =>
      ShortcutsEpic.openSidebarDropdown($issuableSidebar.find('.js-labels-block')),
    );
    Mousetrap.bind(
      keysFor(EPIC_ISSUE_MR_COMMENT_OR_REPLY),
      ShortcutsIssuable.replyWithSelectedText,
    );
    Mousetrap.bind(keysFor(EPIC_ISSUE_MR_EDIT_DESCRIPTION), ShortcutsIssuable.editIssue);
  }

  static openSidebarDropdown($block) {
    if (parseBoolean(Cookies.get('collapsed_gutter'))) {
      document.dispatchEvent(new Event('toggleSidebarRevealLabelsDropdown'));
    } else {
      $block.find('.js-sidebar-dropdown-toggle').get(0).dispatchEvent(new Event('click'));
    }
  }
}
