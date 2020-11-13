import ShortcutsEpic from 'ee/behaviors/shortcuts/shortcuts_epic';
import initEpicApp from 'ee/epic/epic_bundle';
import EpicTabs from 'ee/epic/epic_tabs';
import loadAwardsHandler from '~/awards_handler';
import ZenMode from '~/zen_mode';
import '~/notes/index';

document.addEventListener('DOMContentLoaded', () => {
  new ZenMode(); // eslint-disable-line no-new
  initEpicApp();
  new ShortcutsEpic(); // eslint-disable-line no-new
  new EpicTabs(); // eslint-disable-line no-new
  loadAwardsHandler();
});
