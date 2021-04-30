import apolloProvider from 'ee/subscriptions/buy_minutes/graphql';
import { writeInitialDataToApolloCache } from 'ee/subscriptions/buy_minutes/utils';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
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

  describe('#writeInitialDataToApolloCache', () => {
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
              writeInitialDataToApolloCache(apolloProvider, { groupData: namespaces });
            }).toThrow();
          } else {
            writeInitialDataToApolloCache(apolloProvider, {
              ...DEFAULT_DATA,
              groupData: namespaces,
            });
            const sourceData = await apolloProvider.clients.defaultClient.query({
              query: stateQuery,
            });
            expect(sourceData.data.namespaces).toStrictEqual(parsedNamespaces);
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
              writeInitialDataToApolloCache(apolloProvider, { newUser });
            }).toThrow();
          } else {
            writeInitialDataToApolloCache(apolloProvider, { ...DEFAULT_DATA, newUser });
            const sourceData = await apolloProvider.clients.defaultClient.query({
              query: stateQuery,
            });
            expect(sourceData.data.isNewUser).toEqual(parsedNewUser);
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
          writeInitialDataToApolloCache(apolloProvider, { ...DEFAULT_DATA, fullName });
          const sourceData = await apolloProvider.clients.defaultClient.query({
            query: stateQuery,
          });
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
              writeInitialDataToApolloCache(apolloProvider, { setupForCompany });
            }).toThrow();
          } else {
            writeInitialDataToApolloCache(apolloProvider, {
              ...DEFAULT_DATA,
              newUser: 'true',
              setupForCompany,
            });
            const sourceData = await apolloProvider.clients.defaultClient.query({
              query: stateQuery,
            });
            expect(sourceData.data.isSetupForCompany).toEqual(parsedSetupForCompany);
          }
        });
      });
    });
  });
});
