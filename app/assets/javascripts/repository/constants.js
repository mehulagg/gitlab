import { __ } from '~/locale';

const TREE_PAGE_LIMIT = 1000; // the maximum amount of items per page

export const TREE_PAGE_SIZE = 100; // the amount of items to be fetched per (batch) request
export const TREE_INITIAL_FETCH_COUNT = TREE_PAGE_LIMIT / TREE_PAGE_SIZE; // the amount of (batch) requests to make

export const SECONDARY_OPTIONS_TEXT = __('Cancel');
export const COMMIT_LABEL = __('Commit message');
export const TARGET_BRANCH_LABEL = __('Target branch');
export const TOGGLE_CREATE_MR_LABEL = __('Start a new merge request with these changes');
export const NEW_BRANCH_IN_FORK = __(
  'A new branch will be created in your fork and a new merge request will be started.',
);
