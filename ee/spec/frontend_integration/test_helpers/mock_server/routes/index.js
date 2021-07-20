import defaultRoutes from 'test_helpers/mock_server/routes';

/* eslint-disable global-require */
export default (server) => {
  [require('./vulnerabilities')].forEach(({ default: setup }) => {
    setup(server);
  });

  defaultRoutes(server);
};
