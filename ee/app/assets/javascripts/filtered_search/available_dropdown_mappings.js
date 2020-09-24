import DropdownUser from '~/filtered_search/dropdown_user';
import DropdownNonUser from '~/filtered_search/dropdown_non_user';
import DropdownWeight from './dropdown_weight';
import AvailableDropdownMappingsCE from '~/filtered_search/available_dropdown_mappings';

export default class AvailableDropdownMappings {
  constructor({
    container,
    runnerTagsEndpoint,
    labelsEndpoint,
    milestonesEndpoint,
    epicsEndpoint,
    releasesEndpoint,
    groupsOnly,
    includeAncestorGroups,
    includeDescendantGroups,
  }) {
    this.container = container;
    this.runnerTagsEndpoint = runnerTagsEndpoint;
    this.labelsEndpoint = labelsEndpoint;
    this.milestonesEndpoint = milestonesEndpoint;
    this.epicsEndpoint = epicsEndpoint;
    this.releasesEndpoint = releasesEndpoint;
    this.groupsOnly = groupsOnly;
    this.includeAncestorGroups = includeAncestorGroups;
    this.includeDescendantGroups = includeDescendantGroups;

    this.ceAvailableMappings = new AvailableDropdownMappingsCE({ ...this });
  }

  getAllowedMappings(supportedTokens) {
    const ceMappings = this.ceAvailableMappings.getMappings();

    ceMappings.milestone = {
      reference: null,
      gl: DropdownNonUser,
      extraArguments: {
        endpoint: this.getMilestoneEndpoint(),
        symbol: '%',
      },
      element: this.container.querySelector('#js-dropdown-milestone'),
    };

    ceMappings.approver = {
      reference: null,
      gl: DropdownUser,
      element: this.container.querySelector('#js-dropdown-approver'),
    };

    ceMappings['approved-by'] = {
      reference: null,
      gl: DropdownUser,
      element: this.container.querySelector('#js-dropdown-approved-by'),
    };

    ceMappings.weight = {
      reference: null,
      gl: DropdownWeight,
      element: this.container.querySelector('#js-dropdown-weight'),
    };

    ceMappings.epic = {
      reference: null,
      gl: DropdownNonUser,
      extraArguments: {
        endpoint: this.getEpicEndpoint(),
        symbol: '&',
      },
      element: this.container.querySelector('#js-dropdown-epic'),
    };

    return this.ceAvailableMappings.buildMappings(supportedTokens, ceMappings);
  }

  getMilestoneEndpoint() {
    let endpoint = `${this.milestonesEndpoint}.json`;

    if (this.groupsOnly) {
      endpoint = `${endpoint}?only_group_milestones=true`;
    }

    return endpoint;
  }

  getEpicEndpoint() {
    return `${this.epicsEndpoint}.json`;
  }
}
