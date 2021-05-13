import initGeoNodes from 'ee/geo_nodes';
import { initGeoNodesBeta } from 'ee/geo_nodes_beta';

import PersistentUserCallout from '~/persistent_user_callout';

if (gon.features?.geoNodesBeta) {
  initGeoNodesBeta();
} else {
  initGeoNodes();
  const callout = document.querySelector('.user-callout');
  PersistentUserCallout.factory(callout);
}
