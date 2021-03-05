import { initPathLocks } from 'ee/repository/path_locks';

export default () => {
  initPathLocks({ selector: '.js-file-lock' });
};
