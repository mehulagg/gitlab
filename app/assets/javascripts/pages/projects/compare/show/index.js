import Diff from '~/diff';
import GpgBadges from '~/gpg_badges';
import initChangesDropdown from '~/init_changes_dropdown';

document.addEventListener('DOMContentLoaded', () => {
  new Diff(); // eslint-disable-line no-new
  initChangesDropdown();
  GpgBadges.fetch();
});
