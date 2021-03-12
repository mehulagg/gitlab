import {
  getTypeFromEntityType,
  getEntityTypeFromType,
  parseAuditEventSearchQuery,
  createAuditEventSearchQuery,
} from 'ee/audit_events/utils';

describe('Audit Event Utils', () => {
  describe('getTypeFromEntityType', () => {
    it('returns the correct type when given a valid entity type', () => {
      expect(getTypeFromEntityType('User')).toEqual('user');
    });

    it('returns `undefined` when given an invalid entity type', () => {
      expect(getTypeFromEntityType('ABCDEF')).toBeUndefined();
    });
  });

  describe('getEntityTypeFromType', () => {
    it('returns the correct entity type when given a valid type', () => {
      expect(getEntityTypeFromType('member')).toEqual('Author');
    });

    it('returns `undefined` when given an invalid type', () => {
      expect(getTypeFromEntityType('abcdef')).toBeUndefined();
    });
  });

  describe('parseAuditEventSearchQuery', () => {
    it('returns a query object with parsed date values', () => {
      const input = {
        created_after: '2020-03-13',
        created_before: '2020-04-13',
        sortBy: 'created_asc',
      };

      expect(parseAuditEventSearchQuery(input)).toEqual({
        created_after: new Date('2020-03-13'),
        created_before: new Date('2020-04-13'),
        sortBy: 'created_asc',
      });
    });
  });

  describe('createAuditEventSearchQuery', () => {
    it('returns a query object with remapped keys and stringified dates', () => {
      const input = {
        filterValue: [{ type: 'user', value: { data: '1', operator: '=' } }],
        startDate: new Date('2020-03-13'),
        endDate: new Date('2020-04-13'),
        sortBy: 'bar',
      };

      expect(createAuditEventSearchQuery(input)).toEqual({
        entity_id: '1',
        entity_type: 'User',
        created_after: '2020-03-13',
        created_before: '2020-04-13',
        sort: 'bar',
        page: null,
      });
    });
  });
});
