export const DAILY_TIMELINE_QUERY = /* GraphQL */ `
  query DailyTimeline($rangeStart: ISO8601Date, $rangeEnd: ISO8601Date) {
    dailyPages(rangeStart: $rangeStart, rangeEnd: $rangeEnd) {
      id
      entryDate
      notes {
        id
        title
        summary
        summaryStatus
        createdAt
        updatedAt
        bulletPoints {
          id
          position
          content
        }
        tags {
          id
          name
          similarityGroup
          weight
        }
      }
    }
  }
`;

export const TAGS_QUERY = /* GraphQL */ `
  query Tags {
    tags {
      id
      name
      similarityGroup
    }
  }
`;

export const NOTES_BY_FILTER_QUERY = /* GraphQL */ `
  query Notes($date: ISO8601Date, $tagId: ID) {
    notes(date: $date, tagId: $tagId) {
      id
      title
      summary
      summaryStatus
      createdAt
      bulletPoints {
        id
        position
        content
      }
      tags {
        id
        name
        similarityGroup
        weight
      }
    }
  }
`;

export const NOTE_QUERY = /* GraphQL */ `
  query Note($id: ID!) {
    note(id: $id) {
      id
      title
      summary
      summaryStatus
      createdAt
      updatedAt
      bulletPoints {
        id
        position
        content
      }
      tags {
        id
        name
        similarityGroup
        weight
      }
    }
  }
`;

export const CREATE_NOTE_MUTATION = /* GraphQL */ `
  mutation CreateNote($input: CreateNoteInput!) {
    createNote(input: $input) {
      note {
        id
        title
        summary
        summaryStatus
        createdAt
        updatedAt
      }
    }
  }
`;

export const REQUEST_SUMMARY_MUTATION = /* GraphQL */ `
  mutation RequestSummary($noteId: ID!) {
    requestSummary(noteId: $noteId) {
      note {
        id
        title
        summary
        summaryStatus
        updatedAt
      }
    }
  }
`;

export const SUMMARY_UPDATED_SUBSCRIPTION = /* GraphQL */ `
  subscription SummaryUpdated($noteId: ID!) {
    summaryUpdated(noteId: $noteId) {
      id
      summary
      summaryStatus
      updatedAt
    }
  }
`;
