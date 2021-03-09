import DueDateSelectors from '~/due_date_select';
import initSearchSettings from '~/search_settings';
import initSettingsPanels from '~/settings_panels';

// Initialize expandable settings panels
initSettingsPanels();

new DueDateSelectors(); // eslint-disable-line no-new

initSearchSettings();
