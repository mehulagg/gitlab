import { parsePikadayDate, pikadayToString } from '~/lib/utils/datetime_utility';
import { AVAILABLE_TOKEN_TYPES, AUDIT_FILTER_CONFIGS } from './constants';

export const getTypeFromEntityType = (entityType) => {
  return AUDIT_FILTER_CONFIGS.find(
    ({ entityType: configEntityType }) => configEntityType === entityType,
  )?.type;
};

export const getEntityTypeFromType = (type) => {
  return AUDIT_FILTER_CONFIGS.find(({ type: configType }) => configType === type)?.entityType;
};

export const parseAuditEventSearchQuery = ({
  created_after: createdAfter,
  created_before: createdBefore,
  entity_type: entityType,
  ...restOfParams
}) => ({
  ...restOfParams,
  created_after: createdAfter ? parsePikadayDate(createdAfter) : null,
  created_before: createdBefore ? parsePikadayDate(createdBefore) : null,
  entity_type: getTypeFromEntityType(entityType),
});

export const createAuditEventSearchQuery = ({ filterValue, startDate, endDate, sortBy }) => {
  const entityValue = filterValue.find((value) => AVAILABLE_TOKEN_TYPES.includes(value.type));

  return {
    created_after: startDate ? pikadayToString(startDate) : null,
    created_before: endDate ? pikadayToString(endDate) : null,
    sort: sortBy,
    entity_id: entityValue?.value.data,
    entity_type: getEntityTypeFromType(entityValue?.type),
    // When changing the search parameters, we should be resetting to the first page
    page: null,
  };
};
