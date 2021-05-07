import ShortcutsEpic from 'ee/behaviors/shortcuts/shortcuts_epic';
import initEpicApp from 'ee/epic/epic_bundle';
import EpicTabs from 'ee/epic/epic_tabs';
import loadAwardsHandler from '~/awards_handler';
import ZenMode from '~/zen_mode';
import '~/notes/index';

initEpicApp();

requestIdleCallback(() => {
  const awardEmojiEl = document.getElementById('js-vue-awards-block');

  new EpicTabs(); // eslint-disable-line no-new
  new ShortcutsEpic(); // eslint-disable-line no-new
  if (awardEmojiEl) {
    import('~/emoji/awards_app')
      .then((m) => m.default(awardEmojiEl))
      .catch(() => {});
  } else {
    loadAwardsHandler();
  }
  new ZenMode(); // eslint-disable-line no-new
});
