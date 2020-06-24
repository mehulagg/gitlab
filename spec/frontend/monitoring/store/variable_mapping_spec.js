import {
  parseTemplatingVariables,
  mergeURLVariables,
  optionsFromSeriesData,
} from '~/monitoring/stores/variable_mapping';
import * as urlUtils from '~/lib/utils/url_utility';
import { mockTemplatingData, mockTemplatingDataResponses } from '../mock_data';

describe('Monitoring variable mapping', () => {
  describe('parseTemplatingVariables', () => {
    it.each`
      case                                                                            | input                                         | expected
      ${'Returns empty object for no dashboard input'}                                | ${{}}                                         | ${{}}
      ${'Returns empty object for empty dashboard input'}                             | ${{ dashboard: {} }}                          | ${{}}
      ${'Returns empty object for empty templating prop'}                             | ${mockTemplatingData.emptyTemplatingProp}     | ${{}}
      ${'Returns empty object for empty variables prop'}                              | ${mockTemplatingData.emptyVariablesProp}      | ${{}}
      ${'Returns parsed object for simple text variable'}                             | ${mockTemplatingData.simpleText}              | ${mockTemplatingDataResponses.simpleText}
      ${'Returns parsed object for advanced text variable'}                           | ${mockTemplatingData.advText}                 | ${mockTemplatingDataResponses.advText}
      ${'Returns parsed object for simple custom variable'}                           | ${mockTemplatingData.simpleCustom}            | ${mockTemplatingDataResponses.simpleCustom}
      ${'Returns parsed object for advanced custom variable without options'}         | ${mockTemplatingData.advCustomWithoutOpts}    | ${mockTemplatingDataResponses.advCustomWithoutOpts}
      ${'Returns parsed object for advanced custom variable for option without text'} | ${mockTemplatingData.advCustomWithoutOptText} | ${mockTemplatingDataResponses.advCustomWithoutOptText}
      ${'Returns parsed object for advanced custom variable without type'}            | ${mockTemplatingData.advCustomWithoutType}    | ${{}}
      ${'Returns parsed object for advanced custom variable without label'}           | ${mockTemplatingData.advCustomWithoutLabel}   | ${mockTemplatingDataResponses.advCustomWithoutLabel}
      ${'Returns parsed object for simple and advanced custom variables'}             | ${mockTemplatingData.simpleAndAdv}            | ${mockTemplatingDataResponses.simpleAndAdv}
      ${'Returns parsed object for metricLabelValues'}                                | ${mockTemplatingData.metricLabelValues}       | ${mockTemplatingDataResponses.metricLabelValues}
      ${'Returns parsed object for all variable types'}                               | ${mockTemplatingData.allVariableTypes}        | ${mockTemplatingDataResponses.allVariableTypes}
    `('$case', ({ input, expected }) => {
      expect(parseTemplatingVariables(input?.dashboard?.templating)).toEqual(expected);
    });
  });

  describe('mergeURLVariables', () => {
    beforeEach(() => {
      jest.spyOn(urlUtils, 'queryToObject');
    });

    afterEach(() => {
      urlUtils.queryToObject.mockRestore();
    });

    it('returns empty object if variables are not defined in yml or URL', () => {
      urlUtils.queryToObject.mockReturnValueOnce({});

      expect(mergeURLVariables({})).toEqual({});
    });

    it('returns empty object if variables are defined in URL but not in yml', () => {
      urlUtils.queryToObject.mockReturnValueOnce({
        'var-env': 'one',
        'var-instance': 'localhost',
      });

      expect(mergeURLVariables({})).toEqual({});
    });

    it('returns yml variables if variables defined in yml but not in the URL', () => {
      urlUtils.queryToObject.mockReturnValueOnce({});

      const params = {
        env: 'one',
        instance: 'localhost',
      };

      expect(mergeURLVariables(params)).toEqual(params);
    });

    it('returns yml variables if variables defined in URL do not match with yml variables', () => {
      const urlParams = {
        'var-env': 'one',
        'var-instance': 'localhost',
      };
      const ymlParams = {
        pod: { value: 'one' },
        service: { value: 'database' },
      };
      urlUtils.queryToObject.mockReturnValueOnce(urlParams);

      expect(mergeURLVariables(ymlParams)).toEqual(ymlParams);
    });

    it('returns merged yml and URL variables if there is some match', () => {
      const urlParams = {
        'var-env': 'one',
        'var-instance': 'localhost:8080',
      };
      const ymlParams = {
        instance: { value: 'localhost' },
        service: { value: 'database' },
      };

      const merged = {
        instance: { value: 'localhost:8080' },
        service: { value: 'database' },
      };

      urlUtils.queryToObject.mockReturnValueOnce(urlParams);

      expect(mergeURLVariables(ymlParams)).toEqual(merged);
    });
  });

  describe('optionsFromSeriesData', () => {
    it('fetches the label values from missing data', () => {
      expect(optionsFromSeriesData({ label: 'job' })).toEqual([]);
    });

    it('fetches the label values from a simple series', () => {
      const data = [
        {
          __name__: 'up',
          job: 'job1',
        },
        {
          __name__: 'up',
          job: 'job2',
        },
      ];

      expect(optionsFromSeriesData({ label: 'job', data })).toEqual([
        { text: 'job1', value: 'job1' },
        { text: 'job2', value: 'job2' },
      ]);
    });

    it('fetches the label values from multiple series', () => {
      const data = [
        {
          __name__: 'up',
          job: 'job1',
          instance: 'host1',
        },
        {
          __name__: 'up',
          job: 'job2',
          instance: 'host1',
        },
        {
          __name__: 'up',
          job: 'job1',
          instance: 'host2',
        },
        {
          __name__: 'up',
          job: 'job2',
          instance: 'host2',
        },
      ];

      expect(optionsFromSeriesData({ label: '__name__', data })).toEqual([
        { text: 'up', value: 'up' },
      ]);

      expect(optionsFromSeriesData({ label: 'job', data })).toEqual([
        { text: 'job1', value: 'job1' },
        { text: 'job2', value: 'job2' },
      ]);

      expect(optionsFromSeriesData({ label: 'instance', data })).toEqual([
        { text: 'host1', value: 'host1' },
        { text: 'host2', value: 'host2' },
      ]);
    });

    it('fetches the label values from a series with missing values', () => {
      const data = [
        {
          __name__: 'up',
          job: 'job1',
        },
        {
          __name__: 'up',
          job: 'job2',
        },
        {
          __name__: 'up',
        },
      ];

      expect(optionsFromSeriesData({ label: 'job', data })).toEqual([
        { text: 'job1', value: 'job1' },
        { text: 'job2', value: 'job2' },
      ]);
    });
  });
});
