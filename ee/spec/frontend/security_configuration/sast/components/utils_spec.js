import {
  isValidConfigurationEntity,
  isValidAnalyzerEntity,
  toSastCiConfigurationEntityInput,
  toSastCiConfigurationAnalyzerEntityInput,
} from 'ee/security_configuration/sast/components/utils';
import { makeEntities, makeAnalyzerEntities } from './helpers';

describe('isValidConfigurationEntity', () => {
  const validEntities = makeEntities(3);

  const invalidEntities = [
    null,
    undefined,
    [],
    {},
    ...makeEntities(1, { field: undefined }),
    ...makeEntities(1, { type: undefined }),
    ...makeEntities(1, { description: undefined }),
    ...makeEntities(1, { label: undefined }),
    ...makeEntities(1, { value: undefined }),
    ...makeEntities(1, { defaultValue: undefined }),
  ];

  it.each(validEntities)('returns true for a valid entity', entity => {
    expect(isValidConfigurationEntity(entity)).toBe(true);
  });

  it.each(invalidEntities)('returns false for an invalid entity', invalidEntity => {
    expect(isValidConfigurationEntity(invalidEntity)).toBe(false);
  });
});

describe('isValidAnalyzerEntity', () => {
  const validEntities = makeAnalyzerEntities(3);

  const invalidEntities = [
    null,
    undefined,
    [],
    {},
    ...makeAnalyzerEntities(1, { name: undefined }),
    ...makeAnalyzerEntities(1, { label: undefined }),
    ...makeAnalyzerEntities(1, { enabled: undefined }),
    ...makeAnalyzerEntities(1, { enabled: '' }),
  ];

  it.each(validEntities)('returns true for a valid entity', entity => {
    expect(isValidAnalyzerEntity(entity)).toBe(true);
  });

  it.each(invalidEntities)('returns false for an invalid entity', invalidEntity => {
    expect(isValidAnalyzerEntity(invalidEntity)).toBe(false);
  });
});

describe('toSastCiConfigurationEntityInput', () => {
  let entity;

  describe('given a SastCiConfigurationEntity', () => {
    beforeEach(() => {
      [entity] = makeEntities(1);
    });

    it('returns a SastCiConfigurationEntityInput object', () => {
      expect(toSastCiConfigurationEntityInput(entity)).toEqual({
        field: entity.field,
        defaultValue: entity.defaultValue,
        value: entity.value,
      });
    });
  });
});

describe('toSastCiConfigurationAnalyzerEntityInput', () => {
  let entity;

  describe.each`
    context                                  | enabled  | variables
    ${'a disabled entity with variables'}    | ${false} | ${makeEntities(1)}
    ${'an enabled entity without variables'} | ${true}  | ${undefined}
  `('given $context', ({ enabled, variables }) => {
    beforeEach(() => {
      if (variables) {
        [entity] = makeAnalyzerEntities(1, { enabled, variables: { nodes: variables } });
      } else {
        [entity] = makeAnalyzerEntities(1, { enabled });
      }
    });

    it('returns a SastCiConfigurationAnalyzerEntityInput without variables', () => {
      expect(toSastCiConfigurationAnalyzerEntityInput(entity)).toEqual({
        name: entity.name,
        enabled: entity.enabled,
      });
    });
  });

  describe('given an enabled entity with variables', () => {
    beforeEach(() => {
      [entity] = makeAnalyzerEntities(1, {
        enabled: true,
        variables: { nodes: makeEntities(1) },
      });
    });

    it('returns a SastCiConfigurationAnalyzerEntityInput with variables', () => {
      expect(toSastCiConfigurationAnalyzerEntityInput(entity)).toEqual({
        name: entity.name,
        enabled: entity.enabled,
        variables: [
          {
            field: 'field0',
            defaultValue: 'defaultValue0',
            value: 'value0',
          },
        ],
      });
    });
  });
});
