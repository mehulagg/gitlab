import initEpicBoards from 'ee/epic_boards';
import UsersSelect from '~/users_select';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';

new UsersSelect(); // eslint-disable-line no-new
new ShortcutsNavigation(); // eslint-disable-line no-new
initEpicBoards();
