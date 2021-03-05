import initTree from '~/repository';
import { initPathLocks } from './path_locks';

export default () => {
  const { data } = initTree();

  if (data.pathLocksAvailable) {
    initPathLocks({ selector: '.js-path-lock' });
  }
};
