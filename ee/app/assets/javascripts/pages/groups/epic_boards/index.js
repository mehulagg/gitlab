import initEpicBoards from 'ee/epic_boards';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import UsersSelect from '~/users_select';

new UsersSelect(); // eslint-disable-line no-new
new ShortcutsNavigation(); // eslint-disable-line no-new
initEpicBoards();
