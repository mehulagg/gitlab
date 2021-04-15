import Api from '~/api';

export const resolvers = {
  Query: {
    async runners() {
      const { data } = await Api.getRunners();

      return data.map(async ({ id }) => {
        // CAUTION! N+1!
        const runner = await Api.getRunner(id);

        const { description, ip_address, active, is_shared, name, online, status } = runner.data;

        return {
          id,
          description,
          ipAddress: ip_address,
          active,
          isShared: is_shared,
          name,
          online,
          status,
          __typename: 'Runner', // eslint-disable-line @gitlab/require-i18n-strings
        };
      });
    },
  },
};
