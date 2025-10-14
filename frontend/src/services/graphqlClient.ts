import axios, { AxiosInstance } from 'axios';

type QueryOptions = {
  query: string;
  variables?: Record<string, unknown>;
};

type MutationOptions = QueryOptions;

class SimpleGraphQLClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: '/graphql',
      headers: { 'Content-Type': 'application/json' }
    });
  }

  async query<T>({ query, variables }: QueryOptions): Promise<{ data: T }> {
    const response = await this.client.post('', { query, variables });
    if (response.data.errors) {
      throw new Error(response.data.errors.map((err: any) => err.message).join(', '));
    }
    return { data: response.data.data as T };
  }

  async mutate<T>({ query, variables }: MutationOptions): Promise<{ data: T }> {
    return this.query<T>({ query, variables });
  }
}

export const apolloClient = new SimpleGraphQLClient();
