import createState from 'ee/vue_shared/license_management/store/state';
import * as getters from 'ee/vue_shared/license_management/store/getters';
import { parseLicenseReportMetrics } from 'ee/vue_shared/license_management/store/utils';

import {
  licenseHeadIssues,
  licenseBaseIssues,
  approvedLicense,
  licenseReport as licenseReportMock,
} from 'ee_spec/license_management/mock_data';

describe('getters', () => {
  let state;

  describe('isLoading', () => {
    it('is true if `isLoadingManagedLicenses` is true OR `isLoadingLicenseReport` is true', () => {
      state = createState();
      state.isLoadingManagedLicenses = true;
      state.isLoadingLicenseReport = true;

      expect(getters.isLoading(state)).toBe(true);
      state.isLoadingManagedLicenses = false;
      state.isLoadingLicenseReport = true;

      expect(getters.isLoading(state)).toBe(true);
      state.isLoadingManagedLicenses = true;
      state.isLoadingLicenseReport = false;

      expect(getters.isLoading(state)).toBe(true);
      state.isLoadingManagedLicenses = false;
      state.isLoadingLicenseReport = false;

      expect(getters.isLoading(state)).toBe(false);
    });
  });

  describe('licenseReport', () => {
    describe('with parsedLicenseReport set to false', () => {
      beforeAll(() => {
        gon.features = gon.features || {};
        gon.features.parsedLicenseReport = false;
      });

      it('returns empty array, if the reports are empty', () => {
        state = { ...createState(), headReport: {}, baseReport: {}, managedLicenses: [] };

        expect(getters.licenseReport(state)).toEqual([]);
      });

      it('returns license report, if the license report is not loading', () => {
        state = {
          ...createState(),
          headReport: licenseHeadIssues,
          baseReport: licenseBaseIssues,
          managedLicenses: [approvedLicense],
        };

        expect(getters.licenseReport(state)).toEqual(
          parseLicenseReportMetrics(licenseHeadIssues, licenseBaseIssues, [approvedLicense]),
        );
      });
    });

    describe('with parsedLicenseReport set to true', () => {
      beforeAll(() => {
        gon.features = gon.features || {};
        gon.features.parsedLicenseReport = true;
      });

      afterAll(() => {
        gon.features.parsedLicenseReport = false;
      });

      it('should return the new licenses from the state', () => {
        const newLicenses = { test: 'foo' };
        state = { ...createState(), newLicenses };

        expect(getters.licenseReport(state)).toBe(newLicenses);
      });
    });
  });

  describe('licenseSummaryText', () => {
    describe('when licenses exist on both the HEAD and the BASE', () => {
      beforeEach(() => {
        state = {
          ...createState(),
          loadLicenseReportError: null,
          headReport: licenseHeadIssues,
          baseReport: licenseBaseIssues,
        };
      });

      it('should be `Loading License Compliance report` text if isLoading', () => {
        const mockGetters = {};
        mockGetters.isLoading = true;

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'Loading License Compliance report',
        );
      });

      it('should be `Failed to load License Compliance report` text if an error has happened', () => {
        const mockGetters = {};
        state.loadLicenseReportError = new Error('Test');

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'Failed to load License Compliance report',
        );
      });

      it('should be `License Compliance detected no new licenses`, if the report is empty', () => {
        const mockGetters = { licenseReport: [] };

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'License Compliance detected no new licenses',
        );
      });

      it('should be `License Compliance detected 1 new license`, if the report has one element', () => {
        const mockGetters = { licenseReport: [licenseReportMock[0]] };

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'License Compliance detected 1 new license',
        );
      });

      it('should be `License Compliance detected 2 new licenses`, if the report has two elements', () => {
        const mockGetters = { licenseReport: [licenseReportMock[0], licenseReportMock[0]] };

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'License Compliance detected 2 new licenses',
        );
      });
    });

    describe('when there are no licences on the BASE', () => {
      beforeEach(() => {
        state = { ...createState(), baseReport: {} };
      });

      it('should be `License Compliance detected no licenses for the source branch only` with no new licences', () => {
        const mockGetters = { licenseReport: [] };

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'License Compliance detected no licenses for the source branch only',
        );
      });

      it('should be `License Compliance detected 1 license for the source branch only` with one new licence', () => {
        const mockGetters = { licenseReport: [licenseReportMock[0]] };

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'License Compliance detected 1 license for the source branch only',
        );
      });

      it('should be `License Compliance detected 2 licenses for the source branch only` with two new licences', () => {
        const mockGetters = { licenseReport: [licenseReportMock[0], licenseReportMock[0]] };

        expect(getters.licenseSummaryText(state, mockGetters)).toBe(
          'License Compliance detected 2 licenses for the source branch only',
        );
      });
    });
  });
});
