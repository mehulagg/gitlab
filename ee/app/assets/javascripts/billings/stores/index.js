import subscription from './modules/subscriptions/index';
import seats from './modules/seats/index';

export default () => ({
  modules: {
    subscription,
    seats,
  },
});
