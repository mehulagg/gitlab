import apolloProvider from 'ee/subscriptions/buy_minutes/graphql';
import seedQuery from 'ee/subscriptions/buy_minutes/graphql/queries/seed.query.graphql';
import { writeInitialDataToApolloProvider } from 'ee/subscriptions/buy_minutes/utils';
import {
  mockNamespaces,
  mockParsedNamespaces,
  mockNewUser,
  mockFullName,
  mockSetupForCompany,
} from './mock_data';

const DEFAULT_DATA = {
  groupData: mockNamespaces,
  newUser: mockNewUser,
  fullName: mockFullName,
  setupForCompany: mockSetupForCompany,
};

describe('utils', () => {
  beforeEach(() => {
    apolloProvider.clients.defaultClient.clearStore();
  });

  describe('#writeInitialDataToApolloProvider', () => {
    describe('namespaces', () => {
      describe.each`
        namespaces        | parsedNamespaces        | throws
        ${'[]'}           | ${[]}                   | ${false}
        ${'null'}         | ${{}}                   | ${true}
        ${''}             | ${{}}                   | ${true}
        ${mockNamespaces} | ${mockParsedNamespaces} | ${false}
      `('parameter decoding', ({ namespaces, parsedNamespaces, throws }) => {
        it(`decodes ${namespaces} to ${parsedNamespaces}`, async () => {
          if (throws) {
            expect(() => {
              writeInitialDataToApolloProvider(apolloProvider, { groupData: namespaces });
            }).toThrow();
          } else {
            writeInitialDataToApolloProvider(apolloProvider, {
              ...DEFAULT_DATA,
              groupData: namespaces,
            });
            const sourceData = await apolloProvider.clients.defaultClient.query({
              query: seedQuery,
            });
            expect(sourceData.data.namespaces).toEqual(parsedNamespaces);
          }
        });
      });
    });

    describe('newUser', () => {
      describe.each`
        newUser        | parsedNewUser | throws
        ${'true'}      | ${true}       | ${false}
        ${mockNewUser} | ${false}      | ${false}
        ${''}          | ${false}      | ${true}
      `('parameter decoding', ({ newUser, parsedNewUser, throws }) => {
        it(`decodes ${newUser} to ${parsedNewUser}`, async () => {
          if (throws) {
            expect(() => {
              writeInitialDataToApolloProvider(apolloProvider, { groupData: newUser });
            }).toThrow();
          } else {
            writeInitialDataToApolloProvider(apolloProvider, { ...DEFAULT_DATA, newUser });
            const sourceData = await apolloProvider.clients.defaultClient.query({
              query: seedQuery,
            });
            expect(sourceData.data.newUser).toEqual(parsedNewUser);
          }
        });
      });
    });

    describe('fullName', () => {
      describe.each`
        fullName        | parsedFullName
        ${mockFullName} | ${mockFullName}
        ${''}           | ${''}
        ${null}         | ${null}
      `('parameter decoding', ({ fullName, parsedFullName }) => {
        it(`decodes ${fullName} to ${parsedFullName}`, async () => {
          writeInitialDataToApolloProvider(apolloProvider, { ...DEFAULT_DATA, fullName });
          const sourceData = await apolloProvider.clients.defaultClient.query({ query: seedQuery });
          expect(sourceData.data.fullName).toEqual(parsedFullName);
        });
      });
    });

    describe('setupForCompany', () => {
      describe.each`
        setupForCompany        | parsedSetupForCompany | throws
        ${mockSetupForCompany} | ${true}               | ${false}
        ${'false'}             | ${false}              | ${false}
        ${''}                  | ${false}              | ${true}
      `('parameter decoding', ({ setupForCompany, parsedSetupForCompany, throws }) => {
        it(`decodes ${setupForCompany} to ${parsedSetupForCompany}`, async () => {
          if (throws) {
            expect(() => {
              writeInitialDataToApolloProvider(apolloProvider, { groupData: setupForCompany });
            }).toThrow();
          } else {
            writeInitialDataToApolloProvider(apolloProvider, { ...DEFAULT_DATA, setupForCompany });
            const sourceData = await apolloProvider.clients.defaultClient.query({
              query: seedQuery,
            });
            expect(sourceData.data.setupForCompany).toEqual(parsedSetupForCompany);
          }
        });
      });
    });
  });
});
