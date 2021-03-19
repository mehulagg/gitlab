import { normalizeData as normalizeDataFOSS } from '~/repository/utils/commit';

export function normalizeData(data, path) {
  return normalizeDataFOSS(data, path, (d) => ({
    lockLabel: d.lock_label || false,
  }));
}
