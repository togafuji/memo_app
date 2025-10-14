export interface BulletPointInput {
  position: number;
  content: string;
}

export interface CreateNoteInput {
  title: string;
  entryDate: string;
  bulletPoints: BulletPointInput[];
  tagNames: string[];
}

export interface Tag {
  id: string;
  name: string;
  similarityGroup: number;
  weight?: number;
}

export interface DailyPage {
  id: string;
  entryDate: string;
}

export interface GraphQLNote {
  id: string;
  title: string;
  summary: string | null;
  summaryStatus: 'PENDING' | 'PROCESSING' | 'COMPLETED';
  createdAt: string;
  updatedAt: string;
  bulletPoints: { id: string; position: number; content: string }[];
  tags: Tag[];
}

export interface NoteFilter {
  date?: string;
  tagId?: string;
}
