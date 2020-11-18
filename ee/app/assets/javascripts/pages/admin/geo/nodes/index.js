import initGeoNodes from 'ee/geo_nodes';
import PersistentUserCallout from '~/persistent_user_callout';

initGeoNodes();
const callout = document.querySelector('.user-callout');
PersistentUserCallout.factory(callout);
