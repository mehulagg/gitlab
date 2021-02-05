import { flatten } from 'lodash';
import AccessorUtilities from '~/lib/utils/accessor';
import { s__ } from '~/locale';

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
export const TOGGLE_KEYBOARD_SHORTCUTS_DIALOG = 'globalShortcuts.toggleKeyboardShortcutsDialog';
export const GO_TO_YOUR_PROJECTS = 'globalShortcuts.goToYourProjects';
export const GO_TO_YOUR_GROUPS = 'globalShortcuts.goToYourGroups';
export const GO_TO_ACTIVITY_FEED = 'globalShortcuts.goToActivityFeed';
export const GO_TO_MILESTONE_LIST = 'globalShortcuts.goToMilestoneList';
export const GO_TO_YOUR_SNIPPETS = 'globalShortcuts.goToYourSnippets';
export const START_SEARCH = 'globalShortcuts.startSearch';
export const FOCUS_FILTER_BAR = 'globalShortcuts.focusFilterBar';
export const GO_TO_YOUR_ISSUES = 'globalShortcuts.goToYourIssues';
export const GO_TO_YOUR_MERGE_REQUESTS = 'globalShortcuts.goToYourMergeRequests';
export const GO_TO_YOUR_TODO_LIST = 'globalShortcuts.goToYourTodoList';
export const TOGGLE_PERFORMANCE_BAR = 'globalShortcuts.togglePerformanceBar';
export const TOGGLE_CANARY = 'globalShortcuts.toggleCanary';

export const BOLD_TEXT = 'editing.boldText';
export const ITALIC_TEXT = 'editing.italicText';
export const LINK_TEXT = 'editing.linkText';
export const TOGGLE_MARKDOWN_PREVIEW = 'editing.toggleMarkdownPreview';
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
export const GO_TO_PROJECT_FILES = 'project.goToFiles';
export const GO_TO_PROJECT_FIND_FILE = 'project.goToFindFile';
export const GO_TO_PROJECT_COMMITS = 'project.goToCommits';
export const GO_TO_PROJECT_REPO_GRAPH = 'project.goToRepoGraph';
export const GO_TO_PROJECT_REPO_CHARTS = 'project.goToRepoCharts';
export const GO_TO_PROJECT_ISSUES = 'project.goToIssues';
export const NEW_ISSUE = 'project.newIssue';
export const GO_TO_PROJECT_ISSUE_BOARDS = 'project.goToIssueBoards';
export const GO_TO_PROJECT_MERGE_REQUESTS = 'project.goToMergeRequests';
export const GO_TO_PROJECT_JOBS = 'project.goToJobs';
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

export const ISSUABLE_COMMENT_OR_REPLY = 'issuables.commentReply';
export const ISSUABLE_EDIT_DESCRIPTION = 'issuables.editDescription';
export const ISSUABLE_CHANGE_LABEL = 'issuables.changeLabel';

export const ISSUE_MR_CHANGE_ASSIGNEE = 'issuesMRs.changeAssignee';
export const ISSUE_MR_CHANGE_MILESTONE = 'issuesMRs.changeMilestone';

export const MR_NEXT_FILE_IN_DIFF = 'mergeRequests.nextFileInDiff';
export const MR_PREVIOUS_FILE_IN_DIFF = 'mergeRequests.previousFileInDiff';
export const MR_GO_TO_FILE = 'mergeRequests.goToFile';
export const MR_NEXT_UNRESOLVED_DISCUSSION = 'mergeRequests.nextUnresolvedDiscussion';
export const MR_PREVIOUS_UNRESOLVED_DISCUSSION = 'mergeRequests.previousUnresolvedDiscussion';
export const MR_COPY_SOURCE_BRANCH_NAME = 'mergeRequests.copySourceBranchName';

export const MR_COMMITS_NEXT_COMMIT = 'mergeRequestCommits.nextCommit';
export const MR_COMMITS_PREVIOUS_COMMIT = 'mergeRequestCommits.previousCommit';

export const ISSUE_NEXT_DESIGN = 'issues.nextDesign';
export const ISSUE_PREVIOUS_DESIGN = 'issues.previousDesign';
export const ISSUE_CLOSE_DESIGN = 'issues.closeDesign';

export const WEB_IDE_GO_TO_FILE = 'webIDE.goToFile';
export const WEB_IDE_COMMIT = 'webIDE.commit';

export const METRICS_EXPAND_PANEL = 'metrics.expandPanel';
export const METRICS_VIEW_LOGS = 'metrics.viewLogs';
export const METRICS_DOWNLOAD_CSV = 'metrics.downloadCSV';
export const METRICS_COPY_LINK_TO_CHART = 'metrics.copyLinkToChart';
export const METRICS_SHOW_ALERTS = 'metrics.showAlerts';

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
        description: s__('KeyboardShortcuts|Focus filter bar'),
        command: FOCUS_FILTER_BAR,
        defaultKeys: ['f'],
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
        defaultKeys: ['p b'], // eslint-disable-line @gitlab/require-i18n-strings
      },
    ],
  },
  {
    groupId: 'editing',
    name: s__('KeyboardShortcuts|Editing'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Bold text'),
        command: BOLD_TEXT,
        defaultKeys: ['mod+b'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Italic text'),
        command: ITALIC_TEXT,
        defaultKeys: ['mod+i'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Link text'),
        command: LINK_TEXT,
        defaultKeys: ['mod+k'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Toggle Markdown preview'),
        command: TOGGLE_MARKDOWN_PREVIEW,
        defaultKeys: ['ctrl+shift+p', 'command+shift+p'],
      },
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
        description: s__("KeyboardShortcuts|Go to the project's overview page"),
        command: GO_TO_PROJECT_OVERVIEW,
        defaultKeys: ['g p'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__("KeyboardShortcuts|Go to the project's activity feed"),
        command: GO_TO_PROJECT_ACTIVITY_FEED,
        defaultKeys: ['g v'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to releases'),
        command: GO_TO_PROJECT_RELEASES,
        defaultKeys: ['g r'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to files'),
        command: GO_TO_PROJECT_FILES,
        defaultKeys: ['g f'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to find file'),
        command: GO_TO_PROJECT_FIND_FILE,
        defaultKeys: ['t'],
      },
      {
        description: s__('KeyboardShortcuts|Go to commits'),
        command: GO_TO_PROJECT_COMMITS,
        defaultKeys: ['g c'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to repository graph'),
        command: GO_TO_PROJECT_REPO_GRAPH,
        defaultKeys: ['g n'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to repository charts'),
        command: GO_TO_PROJECT_REPO_CHARTS,
        defaultKeys: ['g d'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to issues'),
        command: GO_TO_PROJECT_ISSUES,
        defaultKeys: ['g i'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|New issue'),
        command: NEW_ISSUE,
        defaultKeys: ['i'],
      },
      {
        description: s__('KeyboardShortcuts|Go to issue boards'),
        command: GO_TO_PROJECT_ISSUE_BOARDS,
        defaultKeys: ['g b'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to merge requests'),
        command: GO_TO_PROJECT_MERGE_REQUESTS,
        defaultKeys: ['g m'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to jobs'),
        command: GO_TO_PROJECT_JOBS,
        defaultKeys: ['g j'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to metrics'),
        command: GO_TO_PROJECT_METRICS,
        defaultKeys: ['g l'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to environments'),
        command: GO_TO_PROJECT_ENVIRONMENTS,
        defaultKeys: ['g e'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to kubernetes'),
        command: GO_TO_PROJECT_KUBERNETES,
        defaultKeys: ['g k'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to snippets'),
        command: GO_TO_PROJECT_SNIPPETS,
        defaultKeys: ['g s'], // eslint-disable-line @gitlab/require-i18n-strings
      },
      {
        description: s__('KeyboardShortcuts|Go to wiki'),
        command: GO_TO_PROJECT_WIKI,
        defaultKeys: ['g w'], // eslint-disable-line @gitlab/require-i18n-strings
      },
    ],
  },
  {
    groupId: 'projectFiles',
    name: s__('KeyboardShortcuts|Project Files'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Move selection up'),
        command: PROJECT_FILES_MOVE_SELECTION_UP,
        defaultKeys: ['up'],
      },
      {
        description: s__('KeyboardShortcuts|Move selection down'),
        command: PROJECT_FILES_MOVE_SELECTION_DOWN,
        defaultKeys: ['down'],
      },
      {
        description: s__('KeyboardShortcuts|Open Selection'),
        command: PROJECT_FILES_OPEN_SELECTION,
        defaultKeys: ['enter'],
      },
      {
        description: s__('KeyboardShortcuts|Go back (while searching for files)'),
        command: PROJECT_FILES_GO_BACK,
        defaultKeys: ['esc'],
      },
      {
        description: s__('KeyboardShortcuts|Go to file permalink (while viewing a file)'),
        command: PROJECT_FILES_GO_TO_PERMALINK,
        defaultKeys: ['y'],
      },
    ],
  },
  {
    groupId: 'epicsIssuesMRs',
    name: s__('KeyboardShortcuts|Epics, Issues, and Merge Requests'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Comment/Reply (quoting selected text)'),
        command: ISSUABLE_COMMENT_OR_REPLY,
        defaultKeys: ['r'],
      },
      {
        description: s__('KeyboardShortcuts|Edit description'),
        command: ISSUABLE_EDIT_DESCRIPTION,
        defaultKeys: ['e'],
      },
      {
        description: s__('KeyboardShortcuts|Change label'),
        command: ISSUABLE_CHANGE_LABEL,
        defaultKeys: ['l'],
      },
    ],
  },
  {
    groupId: 'issuesMRs',
    name: s__('KeyboardShortcuts|Issues and Merge Requests'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Change assignee'),
        command: ISSUE_MR_CHANGE_ASSIGNEE,
        defaultKeys: ['a'],
      },
      {
        description: s__('KeyboardShortcuts|Change milestone'),
        command: ISSUE_MR_CHANGE_MILESTONE,
        defaultKeys: ['m'],
      },
    ],
  },
  {
    groupId: 'mergeRequests',
    name: s__('KeyboardShortcuts|Merge Requests'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Next file in diff'),
        command: MR_NEXT_FILE_IN_DIFF,
        defaultKeys: [']', 'j'],
      },
      {
        description: s__('KeyboardShortcuts|Previous file in diff'),
        command: MR_PREVIOUS_FILE_IN_DIFF,
        defaultKeys: ['[', 'k'],
      },
      {
        description: s__('KeyboardShortcuts|Go to file'),
        command: MR_GO_TO_FILE,
        defaultKeys: ['t', 'mod+p'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Next unresolved discussion'),
        command: MR_NEXT_UNRESOLVED_DISCUSSION,
        defaultKeys: ['n'],
      },
      {
        description: s__('KeyboardShortcuts|Previous unresolved discussion'),
        command: MR_PREVIOUS_UNRESOLVED_DISCUSSION,
        defaultKeys: ['p'],
      },
      {
        description: s__('KeyboardShortcuts|Copy source branch name'),
        command: MR_COPY_SOURCE_BRANCH_NAME,
        defaultKeys: ['b'],
      },
    ],
  },
  {
    groupId: 'mergeRequestCommits',
    name: s__('KeyboardShortcuts|Merge Request Commits'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Next commit'),
        command: MR_COMMITS_NEXT_COMMIT,
        defaultKeys: ['c'],
      },
      {
        description: s__('KeyboardShortcuts|Previous commit'),
        command: MR_COMMITS_PREVIOUS_COMMIT,
        defaultKeys: ['x'],
      },
    ],
  },
  {
    groupId: 'issues',
    name: s__('KeyboardShortcuts|Issues'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Next design'),
        command: ISSUE_NEXT_DESIGN,
        defaultKeys: ['right'],
      },
      {
        description: s__('KeyboardShortcuts|Previous design'),
        command: ISSUE_PREVIOUS_DESIGN,
        defaultKeys: ['left'],
      },
      {
        description: s__('KeyboardShortcuts|Close design'),
        command: ISSUE_CLOSE_DESIGN,
        defaultKeys: ['esc'],
      },
    ],
  },
  {
    groupId: 'webIDE',
    name: s__('KeyboardShortcuts|Web IDE'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Go to file'),
        command: WEB_IDE_GO_TO_FILE,
        defaultKeys: ['mod+p'],
      },
      {
        description: s__('KeyboardShortcuts|Commit (when editing commit message)'),
        command: WEB_IDE_COMMIT,
        defaultKeys: ['mod+enter'],
        customizable: false,
      },
    ],
  },
  {
    groupId: 'metrics',
    name: s__('KeyboardShortcuts|Metrics'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Expand panel'),
        command: METRICS_EXPAND_PANEL,
        defaultKeys: ['e'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|View logs'),
        command: METRICS_VIEW_LOGS,
        defaultKeys: ['l'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Download CSV'),
        command: METRICS_DOWNLOAD_CSV,
        defaultKeys: ['d'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Copy link to chart'),
        command: METRICS_COPY_LINK_TO_CHART,
        defaultKeys: ['c'],
        customizable: false,
      },
      {
        description: s__('KeyboardShortcuts|Alerts'),
        command: METRICS_SHOW_ALERTS,
        defaultKeys: ['a'],
        customizable: false,
      },
    ],
  },
  {
    groupId: 'misc',
    name: s__('KeyboardShortcuts|Miscellaneous'),
    keybindings: [
      {
        description: s__('KeyboardShortcuts|Toggle GitLab Next'),
        command: TOGGLE_CANARY,
        // eslint-disable-next-line @gitlab/require-i18n-strings
        defaultKeys: ['g x'],
      },
    ],
  },
]

  // For each keybinding object, add a `customKeys` property populated with the
  // user's custom keybindings (if the command has been customized).
  // `customKeys` will be `undefined` if the command hasn't been customized.
  .map((group) => {
    return {
      ...group,
      keybindings: group.keybindings.map((binding) => ({
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
const commandToKeys = flatten(keybindingGroups.map((group) => group.keybindings)).reduce(
  (acc, binding) => {
    if (binding.customizable === false) {
      // if the command is defined with customizable: false,
      // don't allow this command to be customized.
      acc[binding.command] = binding.defaultKeys;
    } else {
      acc[binding.command] = binding.customKeys || binding.defaultKeys;
    }

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
export const keysFor = (command) => {
  return commandToKeys[command];
};
