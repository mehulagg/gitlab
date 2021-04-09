import ShortcutsEpic from 'ee/behaviors/shortcuts/shortcuts_epic';
import initEpicApp from 'ee/epic/epic_bundle';
import EpicTabs from 'ee/epic/epic_tabs';
import initEpicShowApp from 'ee/epic_show/epic_show_bundle';
import loadAwardsHandler from '~/awards_handler';
import ZenMode from '~/zen_mode';
import '~/notes/index';

initEpicApp();

requestIdleCallback(() => {
  if (gon.features.vueEpicShow) {
    initEpicShowApp({
      mountPointSelector: '#js-epic-show-app',
    });
  } else {
    new EpicTabs(); // eslint-disable-line no-new
    new ShortcutsEpic(); // eslint-disable-line no-new
    loadAwardsHandler();
    new ZenMode(); // eslint-disable-line no-new
  }
});
