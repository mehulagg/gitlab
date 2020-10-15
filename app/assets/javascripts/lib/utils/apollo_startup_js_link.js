import { ApolloLink, Observable } from 'apollo-link';
import { parse } from 'graphql';

export class StartupJSLink extends ApolloLink {
  constructor() {
    super();
    // FetchResult
    this.fetchResult = null;
    this.queryResults = null;
    this.startupCalls = new Map();
    this.fetchCall = window.gl?.startup_graphql_calls?.fetchCall;
    this.parseStartupCalls(window.gl?.startup_graphql_calls?.calls || []);
  }

  // Extract operationNames from the queries and ensure that we can
  // match operationName => element from result array
  parseStartupCalls(calls) {
    calls.forEach((call, index) => {
      const { query, variables } = call;
      const operationName = parse(query)?.definitions?.find(x => x.kind === 'OperationDefinition')
        ?.name?.value;

      if (operationName) {
        this.startupCalls.set(operationName, {
          index,
          variables,
        });
      }
    });
  }

  async getResult(index) {
    if (!this.queryResults) {
      this.queryResults = this.fetchCall.then(res => {
        // Handle HTTP errors
        if (!res.ok) {
          throw new Error('fetchCall failed');
        }
        this.fetchResult = res;
        return res.json();
      });
    }

    return (await this.queryResults)[index];
  }

  static noopRequest = (operation, forward) => forward(operation);

  disable() {
    this.request = StartupJSLink.noopRequest;
    this.fetchResult = null;
    this.startupCalls = null;
    this.queryResults = null;
  }

  request(operation, forward) {
    // Disable StartupJSLink in case all calls are done or none are set up
    if ((this.startupCalls && this.startupCalls.size === 0) || !this.fetchCall) {
      this.disable();
      return forward(operation);
    }

    const { operationName } = operation;

    // Skip startup call if the operationName doesn't match
    if (!this.startupCalls.has(operationName)) {
      return forward(operation);
    }

    const { variables: startupVariables, index } = this.startupCalls.get(operationName);
    this.startupCalls.delete(operationName);

    // Skip startup call if the variables values do not match
    const variables = Object.entries(operation.variables || {});
    for (let i = 0; i < variables.length; i += 1) {
      const [key, value] = variables[i];
      if (startupVariables[key] !== value) {
        return forward(operation);
      }
    }

    return new Observable(observer => {
      this.getResult(index)
        .then(result => {
          operation.setContext({ response: this.fetchResult });
          // we have data and can send it to back up the link chain
          observer.next(result);
          observer.complete();
        })
        .catch(() => {
          // StartupJS somehow failed, so let's forward it down the pipe
          this.disable();
          forward(operation).subscribe({
            next: result => {
              observer.next(result);
            },
            error: error => {
              observer.error(error);
            },
            complete: observer.complete.bind(observer),
          });
        });
    });
  }
}
