import ShortcutsEpic from 'ee/behaviors/shortcuts/shortcuts_epic';
import initEpicApp from 'ee/epic/epic_bundle';
import EpicTabs from 'ee/epic/epic_tabs';
import loadAwardsHandler from '~/awards_handler';
import ZenMode from '~/zen_mode';
import '~/notes/index';

initEpicApp();

requestIdleCallback(() => {
  new EpicTabs(); // eslint-disable-line no-new
  new ShortcutsEpic(); // eslint-disable-line no-new
  loadAwardsHandler();
  new ZenMode(); // eslint-disable-line no-new
});
