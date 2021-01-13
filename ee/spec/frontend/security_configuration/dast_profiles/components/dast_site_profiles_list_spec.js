import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { within } from '@testing-library/dom';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import createApolloProvider from 'helpers/mock_apollo_helper';
import dastSiteValidationsQuery from 'ee/security_configuration/dast_site_validation/graphql/dast_site_validations.query.graphql';
import Component from 'ee/security_configuration/dast_profiles/components/dast_site_profiles_list.vue';
import ProfilesList from 'ee/security_configuration/dast_profiles/components/dast_profiles_list.vue';
import { updateSiteProfilesStatuses } from 'ee/security_configuration/dast_profiles/graphql/cache_utils';
import { DAST_SITE_VALIDATION_STATUS } from 'ee/security_configuration/dast_site_validation/constants';
import { siteProfiles } from '../mocks/mock_data';
import * as responses from '../mocks/apollo_mock';

jest.mock('ee/security_configuration/dast_profiles/graphql/cache_utils', () => ({
  updateSiteProfilesStatuses: jest.fn(),
}));

describe('EE - DastSiteProfileList', () => {
  let localVue;
  let wrapper;
  let requestHandlers;
  let apolloProvider;

  const defaultProps = {
    profiles: [],
    tableLabel: 'Site profiles',
    fields: [{ key: 'profileName' }, { key: 'targetUrl' }, { key: 'validationStatus' }],
    profilesPerPage: 10,
    errorMessage: '',
    errorDetails: [],
    fullPath: '/namespace/project',
    hasMoreProfilesToLoad: false,
    isLoading: false,
  };

  const createMockApolloProvider = (handlers) => {
    localVue.use(VueApollo);
    requestHandlers = handlers;
    return createApolloProvider([[dastSiteValidationsQuery, requestHandlers.dastSiteValidations]]);
  };

  const wrapperFactory = (mountFn = shallowMount) => (options = {}, handlers) => {
    localVue = createLocalVue();
    apolloProvider = handlers && createMockApolloProvider(handlers);
    wrapper = mountFn(
      Component,
      merge(
        {
          propsData: defaultProps,
          provide: {
            glFeatures: { securityOnDemandScansSiteValidation: true },
          },
        },
        { ...options, localVue, apolloProvider },
      ),
    );
  };
  const createComponent = wrapperFactory();
  const createFullComponent = wrapperFactory(mount);

  const withinComponent = () => within(wrapper.element);
  const getTable = () => withinComponent().getByRole('table', { name: /profiles/i });
  const getAllRowGroups = () => within(getTable()).getAllByRole('rowgroup');
  const getTableBody = () => {
    // first item is the table head
    const [, tableBody] = getAllRowGroups();
    return tableBody;
  };
  const getAllTableRows = () => within(getTableBody()).getAllByRole('row');
  const getTableRowForProfile = (profile) => getAllTableRows()[siteProfiles.indexOf(profile)];

  const findProfileList = () => wrapper.find(ProfilesList);

  afterEach(() => {
    wrapper.destroy();
    apolloProvider = null;
  });

  it('renders profile list properly', () => {
    createComponent({
      propsData: { profiles: siteProfiles },
    });

    expect(findProfileList()).toExist();
  });

  it('passes down the props properly', () => {
    createFullComponent();

    expect(findProfileList().props()).toEqual(defaultProps);
  });

  it('sets listeners on profile list component', () => {
    const inputHandler = jest.fn();
    createComponent({
      listeners: {
        input: inputHandler,
      },
    });
    findProfileList().vm.$emit('input');

    expect(inputHandler).toHaveBeenCalled();
  });

  describe('with site validation enabled', () => {
    const [pendingValidation, inProgressValidation] = siteProfiles;
    const urlsPendingValidation = [
      pendingValidation.normalizedTargetUrl,
      inProgressValidation.normalizedTargetUrl,
    ];

    beforeEach(() => {
      createFullComponent(
        { propsData: { profiles: siteProfiles } },
        {
          dastSiteValidations: jest.fn().mockResolvedValue(
            responses.dastSiteValidations([
              {
                normalizedTargetUrl: pendingValidation.normalizedTargetUrl,
                status: DAST_SITE_VALIDATION_STATUS.FAILED,
              },
              {
                normalizedTargetUrl: inProgressValidation.normalizedTargetUrl,
                status: DAST_SITE_VALIDATION_STATUS.PASSED,
              },
            ]),
          ),
        },
      );
    });

    describe.each`
      status           | statusEnum                                | label                  | hasValidateButton
      ${'no'}          | ${DAST_SITE_VALIDATION_STATUS.NONE}       | ${''}                  | ${true}
      ${'pending'}     | ${DAST_SITE_VALIDATION_STATUS.PENDING}    | ${'Validating...'}     | ${false}
      ${'in-progress'} | ${DAST_SITE_VALIDATION_STATUS.INPROGRESS} | ${'Validating...'}     | ${false}
      ${'passed'}      | ${DAST_SITE_VALIDATION_STATUS.PASSED}     | ${'Validated'}         | ${false}
      ${'failed'}      | ${DAST_SITE_VALIDATION_STATUS.FAILED}     | ${'Validation failed'} | ${true}
    `('profile with $status validation', ({ statusEnum, label, hasValidateButton }) => {
      const profile = siteProfiles.find(({ validationStatus }) => validationStatus === statusEnum);

      it(`should show correct label`, () => {
        const validationStatusCell = getTableRowForProfile(profile).cells[2];
        expect(validationStatusCell.innerText).toContain(label);
      });

      it(`should ${hasValidateButton ? 'not ' : ''} disable validate button`, () => {
        const actionsCell = getTableRowForProfile(profile).cells[3];
        const validateButton = within(actionsCell).queryByRole('button', {
          name: /validate|Retry validation/i,
        });

        expect(validateButton.hasAttribute('disabled')).toBe(!hasValidateButton);
      });
    });

    it('fetches validation statuses for all profiles that are being validated and updates the cache', () => {
      expect(requestHandlers.dastSiteValidations).toHaveBeenCalledWith({
        fullPath: defaultProps.fullPath,
        urls: urlsPendingValidation,
      });
      expect(updateSiteProfilesStatuses).toHaveBeenCalledTimes(2);
    });

    it.each`
      nthCall | normalizedTargetUrl                         | status
      ${1}    | ${pendingValidation.normalizedTargetUrl}    | ${DAST_SITE_VALIDATION_STATUS.FAILED}
      ${2}    | ${inProgressValidation.normalizedTargetUrl} | ${DAST_SITE_VALIDATION_STATUS.PASSED}
    `(
      'in the local cache, profile with normalized URL $normalizedTargetUrl has its status set to $status',
      ({ nthCall, normalizedTargetUrl, status }) => {
        expect(updateSiteProfilesStatuses).toHaveBeenNthCalledWith(nthCall, {
          fullPath: defaultProps.fullPath,
          normalizedTargetUrl,
          status,
          store: apolloProvider.defaultClient,
        });
      },
    );
  });

  describe('without site validation enabled', () => {
    beforeEach(() => {
      createFullComponent({
        provide: {
          glFeatures: { securityOnDemandScansSiteValidation: false },
        },
        propsData: { siteProfiles },
      });
    });

    it.each(siteProfiles)('profile %# should not have validate button and status', (profile) => {
      const [, , validationStatusCell, actionsCell] = getTableRowForProfile(profile).cells;

      expect(within(actionsCell).queryByRole('button', { name: /validate/i })).toBe(null);
      expect(validationStatusCell.innerText).toBe('');
    });
  });
});
