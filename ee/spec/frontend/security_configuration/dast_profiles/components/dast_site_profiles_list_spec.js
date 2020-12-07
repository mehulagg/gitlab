import { mount, shallowMount } from '@vue/test-utils';
import { within } from '@testing-library/dom';
import { merge } from 'lodash';
import Component from 'ee/security_configuration/dast_profiles/components/dast_site_profiles_list.vue';
import ProfilesList from 'ee/security_configuration/dast_profiles/components/dast_profiles_list.vue';
import { siteProfiles } from './mock_data';

describe('EE - DastSiteProfileList', () => {
  let wrapper;

  const defaultProps = {
    profiles: [],
    tableLabel: 'Site profiles',
    fields: ['profileName', 'targetUrl', 'validationStatus'],
    profilesPerPage: 10,
    errorMessage: '',
    errorDetails: [],
    fullPath: '/namespace/project',
    hasMoreProfilesToLoad: false,
    isLoading: false,
  };

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      Component,
      merge(
        {
          propsData: defaultProps,
          provide: {
            glFeatures: { securityOnDemandScansSiteValidation: true },
          },
        },
        options,
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
  const getTableRowForProfile = profile => getAllTableRows()[siteProfiles.indexOf(profile)];

  const findProfileList = () => wrapper.find(ProfilesList);

  afterEach(() => {
    wrapper.destroy();
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
    beforeEach(() => {
      createFullComponent({ propsData: { siteProfiles } });
    });

    describe.each`
      status           | statusEnum                 | label                  | hasValidateButton
      ${'no'}          | ${'NONE'}                  | ${''}                  | ${true}
      ${'pending'}     | ${'PENDING_VALIDATION'}    | ${'Validating...'}     | ${false}
      ${'in-progress'} | ${'INPROGRESS_VALIDATION'} | ${'Validating...'}     | ${false}
      ${'passed'}      | ${'PASSED_VALIDATION'}     | ${'Validated'}         | ${false}
      ${'failed'}      | ${'FAILED_VALIDATION'}     | ${'Validation failed'} | ${true}
    `('profile with $status validation', ({ statusEnum, label, hasValidateButton }) => {
      const profile = siteProfiles.find(({ validationStatus }) => validationStatus === statusEnum);

      it(`should show correct label`, () => {
        const validationStatusCell = getTableRowForProfile(profile).cells[2];
        expect(validationStatusCell.innerText).toContain(label);
      });

      it(`should ${hasValidateButton ? '' : 'not '}render validate button`, () => {
        const actionsCell = getTableRowForProfile(profile).cells[3];
        const validateButton = within(actionsCell).queryByRole('button', {
          name: /validate/i,
        });

        if (hasValidateButton) {
          expect(validateButton).not.toBeNull();
        } else {
          expect(validateButton).toBeNull();
        }
      });
    });
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

    it.each(siteProfiles)('profile %# should not have validate button and status', profile => {
      const [, , validationStatusCell, actionsCell] = getTableRowForProfile(profile).cells;

      expect(within(actionsCell).queryByRole('button', { name: /validate/i })).toBe(null);
      expect(validationStatusCell.innerText).toBe('');
    });
  });
});
