import { initIterationReport } from 'ee/iterations';
import { Namespace } from 'ee/iterations/constants';

document.addEventListener('DOMContentLoaded', () => {
  initIterationReport({ namespaceType: Namespace.Group });
});
