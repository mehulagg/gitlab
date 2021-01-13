import $ from 'jquery';
import Mousetrap from 'mousetrap';
import Cookies from 'js-cookie';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import { parseBoolean } from '~/lib/utils/common_utils';

export default class ShortcutsEpic extends ShortcutsIssuable {
  constructor() {
    super();

    const $issuableSidebar = $('.js-issuable-update');

    Mousetrap.bind('l', () =>
      ShortcutsEpic.openSidebarDropdown($issuableSidebar.find('.js-labels-block')),
    );
    Mousetrap.bind('r', ShortcutsIssuable.replyWithSelectedText);
    Mousetrap.bind('e', ShortcutsIssuable.editIssue);
  }

  static openSidebarDropdown($block) {
    if (parseBoolean(Cookies.get('collapsed_gutter'))) {
      document.dispatchEvent(new Event('toggleSidebarRevealLabelsDropdown'));
    } else {
      $block.find('.js-sidebar-dropdown-toggle').get(0).dispatchEvent(new Event('click'));
    }
  }
}
