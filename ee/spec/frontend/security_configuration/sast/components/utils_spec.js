import {
  toSastCiConfigurationEntityInput,
  toSastCiConfigurationAnalyzerEntityInput,
} from 'ee/security_configuration/sast/components/utils';
import { makeEntities, makeAnalyzerEntities } from '../../helpers';

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
