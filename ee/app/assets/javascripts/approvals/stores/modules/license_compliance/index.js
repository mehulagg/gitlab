import base from '../base';
import * as actions from './actions';

export { APPROVALS, APPROVALS_MODAL } from './constants';

export default () => ({
  ...base(),
  actions,
});
