import { flatten } from 'lodash';
import { s__ } from '~/locale';
import AccessorUtilities from '~/lib/utils/accessor';
import { shouldDisableShortcuts } from './shortcuts_toggle';

export const LOCAL_STORAGE_KEY = 'gl-keyboard-shortcuts-customizations';

let parsedCustomizations = {};
const localStorageIsSafe = AccessorUtilities.isLocalStorageAccessSafe();

if (localStorageIsSafe) {
  try {
    parsedCustomizations = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) || '{}');
  } catch (e) {
    /* do nothing */
  }
}

/**
 * A map of command => keys of all keyboard shortcuts
 * that have been customized by the user.
 *
 * @example
 * { "globalShortcuts.togglePerformanceBar": ["p e r f"] }
 *
 * @type { Object.<string, string[]> }
 */
export const customizations = parsedCustomizations;

// All available commands
export const TOGGLE_PERFORMANCE_BAR = 'globalShortcuts.togglePerformanceBar';
export const TOGGLE_KEYBOARD_SHORTCUTS_DIALOG = 'globalShortcuts.toggleKeyboardShortcutsDialog';
export const GO_TO_YOUR_PROJECTS = 'globalShortcuts.goToYourProjects';
export const GO_TO_YOUR_GROUPS = 'globalShortcuts.goToYourGroups';
export const GO_TO_ACTIVITY_FEED = 'globalShortcuts.goToActivityFeed';
export const GO_TO_MILESTONE_LIST = 'globalShortcuts.goToMilestoneList';
export const GO_TO_YOUR_SNIPPETS = 'globalShortcuts.goToYourSnippets';
export const START_SEARCH = 'globalShortcuts.startSearch';
export const GO_TO_YOUR_ISSUES = 'globalShortcuts.goToYourIssues';
export const GO_TO_YOUR_MERGE_REQUESTS = 'globalShortcuts.goToYourMergeRequests';
export const GO_TO_YOUR_TODO_LIST = 'globalShortcuts.goToYourTodoList';

export const EDIT_RECENT_COMMENT = 'editing.editRecentComment';

export const EDIT_WIKI_PAGE = 'wiki.editWikiPage';

export const REPO_GRAPH_SCROLL_LEFT = 'repositoryGraph.scrollLeft';
export const REPO_GRAPH_SCROLL_RIGHT = 'repositoryGraph.scrollRight';
export const REPO_GRAPH_SCROLL_UP = 'repositoryGraph.scrollUp';
export const REPO_GRAPH_SCROLL_DOWN = 'repositoryGraph.scrollDown';
export const REPO_GRAPH_SCROLL_TOP = 'repositoryGraph.scrollToTop';
export const REPO_GRAPH_SCROLL_BOTTOM = 'repositoryGraph.scrollToBottom';

export const GO_TO_PROJECT_OVERVIEW = 'project.goToOverview';
export const GO_TO_PROJECT_ACTIVITY_FEED = 'project.goToActivityFeed';
export const GO_TO_PROJECT_RELEASES = 'project.goToReleases';
export const GO_TO_FILES = 'project.goToFiles';
export const GO_TO_FIND_FILE = 'project.goToFindFile';
export const GO_TO_COMMITS = 'project.goToCommits';
export const GO_TO_REPO_GRAPH = 'project.goToRepoGraph';
export const GO_TO_REPO_CHARTS = 'project.goToRepoCharts';
export const GO_TO_PROJECT_ISSUES = 'project.goToIssues';
export const NEW_ISSUE = 'project.newIssue';
export const GO_TO_ISSUE_BOARDS = 'project.goToIssueBoards';
export const GO_TO_MERGE_REQUESTS = 'project.goToMergeRequests';
export const GO_TO_JOBS = 'project.goToJobs';
export const GO_TO_PROJECT_METRICS = 'project.goToMetrics';
export const GO_TO_PROJECT_ENVIRONMENTS = 'project.goToEnvironments';
export const GO_TO_PROJECT_KUBERNETES = 'project.goToKubernetes';
export const GO_TO_PROJECT_SNIPPETS = 'project.goToSnippets';
export const GO_TO_PROJECT_WIKI = 'project.goToWiki';

export const PROJECT_FILES_MOVE_SELECTION_UP = 'projectFiles.moveSelectionUp';
export const PROJECT_FILES_MOVE_SELECTION_DOWN = 'projectFiles.moveSelectionDown';
export const PROJECT_FILES_OPEN_SELECTION = 'projectFiles.openSelection';
export const PROJECT_FILES_GO_BACK = 'projectFiles.goBack';
export const PROJECT_FILES_GO_TO_PERMALINK = 'projectFiles.goToFilePermalink';

/** All keybindings, grouped and ordered with descriptions */
export const keybindingGroups = [
  {
    groupId: 'globalShortcuts',
    name: s__('KeyboardShortcuts|Global Shortcuts'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Toggle keyboard shortcuts help dialog'),
        command: TOGGLE_KEYBOARD_SHORTCUTS_DIALOG,
        defaultKeys: ['?'],
      },
      {
        description: s__('KeyboardShortcuts|Go to your projects'),
        command: GO_TO_YOUR_PROJECTS,
        defaultKeys: ['shift+p'],
      },
      {
        description: s__('KeyboardShortcuts|Go to your groups'),
        command: GO_TO_YOUR_GROUPS,
        defaultKeys: ['shift+g'],
      },
      {
        description: s__('KeyboardShortcuts|Go to the activity feed'),
        command: GO_TO_ACTIVITY_FEED,
        defaultKeys: ['shift+a'],
      },
      {
        description: s__('KeyboardShortcuts|Go to the milestone list'),
        command: GO_TO_MILESTONE_LIST,
        defaultKeys: ['shift+l'],
      },
      {
        description: s__('KeyboardShortcuts|Go to your snippets'),
        command: GO_TO_YOUR_SNIPPETS,
        defaultKeys: ['shift+s'],
      },
      {
        description: s__('KeyboardShortcuts|Start search'),
        command: START_SEARCH,
        defaultKeys: ['s', '/'],
      },
      {
        description: s__('KeyboardShortcuts|Go to your issues'),
        command: GO_TO_YOUR_ISSUES,
        defaultKeys: ['shift+i'],
      },
      {
        description: s__('KeyboardShortcuts|Go to your merge requests'),
        command: GO_TO_YOUR_MERGE_REQUESTS,
        defaultKeys: ['shift+m'],
      },
      {
        description: s__('KeyboardShortcuts|Go to your To-Do list'),
        command: GO_TO_YOUR_TODO_LIST,
        defaultKeys: ['shift+t'],
      },
      {
        description: s__('KeyboardShortcuts|Toggle the Performance Bar'),
        command: TOGGLE_PERFORMANCE_BAR,
        // eslint-disable-next-line @gitlab/require-i18n-strings
        defaultKeys: ['p b'],
      },
    ],
  },
  {
    groupId: 'editing',
    name: s__('KeyboardShortcuts|Editing'),
    keybindings: [
      {
        description: s__(
          'KeyboardShortcuts|Edit your most recent comment in a thread (from an empty textarea)',
        ),
        command: EDIT_RECENT_COMMENT,
        defaultKeys: ['up'],
      },
    ],
  },
  {
    groupId: 'wiki',
    name: s__('KeyboardShortcuts|Wiki'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Edit wiki page'),
        command: EDIT_WIKI_PAGE,
        defaultKeys: ['e'],
      },
    ],
  },
  {
    groupId: 'repositoryGraph',
    name: s__('KeyboardShortcuts|Repository Graph'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Scroll left'),
        command: REPO_GRAPH_SCROLL_LEFT,
        defaultKeys: ['left', 'h'],
      },
      {
        description: s__('KeyboardShortcuts|Scroll right'),
        command: REPO_GRAPH_SCROLL_RIGHT,
        defaultKeys: ['right', 'l'],
      },
      {
        description: s__('KeyboardShortcuts|Scroll up'),
        command: REPO_GRAPH_SCROLL_UP,
        defaultKeys: ['up', 'k'],
      },
      {
        description: s__('KeyboardShortcuts|Scroll down'),
        command: REPO_GRAPH_SCROLL_DOWN,
        defaultKeys: ['down', 'j'],
      },
      {
        description: s__('KeyboardShortcuts|Scroll to top'),
        command: REPO_GRAPH_SCROLL_TOP,
        defaultKeys: ['shift+up', 'shift+k'],
      },
      {
        description: s__('KeyboardShortcuts|Scroll to bottom'),
        command: REPO_GRAPH_SCROLL_BOTTOM,
        defaultKeys: ['shift+down', 'shift+j'],
      },
    ],
  },
  {
    groupId: 'project',
    name: s__('KeyboardShortcuts|Project'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Go to the project\'s overview page'),
        command: GO_TO_PROJECT_OVERVIEW,
        defaultKeys: ['g p'],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
      {
        description: s__('KeyboardShortcuts|'),
        command: ,
        defaultKeys: [''],
      },
    ],
  },
]

  // For each keybinding object, add a `customKeys` property populated with the
  // user's custom keybindings (if the command has been customized).
  // `customKeys` will be `undefined` if the command hasn't been customized.
  .map(group => {
    return {
      ...group,
      keybindings: group.keybindings.map(binding => ({
        ...binding,
        customKeys: customizations[binding.command],
      })),
    };
  });

/**
 * A simple map of command => keys. All user customizations are included in this map.
 * This mapping is used to simplify `keysFor` below.
 *
 * @example
 * { "globalShortcuts.togglePerformanceBar": ["p e r f"] }
 */
const commandToKeys = flatten(keybindingGroups.map(group => group.keybindings)).reduce(
  (acc, binding) => {
    acc[binding.command] = binding.customKeys || binding.defaultKeys;
    return acc;
  },
  {},
);

/**
 * Gets keyboard shortcuts associated with a command
 *
 * @param {string} command The command string. All command
 * strings are available as imports from this file.
 *
 * @returns {string[]} An array of keyboard shortcut strings bound to the command
 *
 * @example
 * import { keysFor, TOGGLE_PERFORMANCE_BAR } from '~/behaviors/shortcuts/keybindings'
 *
 * Mousetrap.bind(keysFor(TOGGLE_PERFORMANCE_BAR), handler);
 */
export const keysFor = command => {
  if (shouldDisableShortcuts()) {
    return [];
  }

  return commandToKeys[command];
};
