import { memoize } from 'lodash';

export const loadSmooshpackModule = memoize(() =>
  gon.features.useSmooshpackFork ? import('gitlab-smooshpack') : import('smooshpack'),
);
