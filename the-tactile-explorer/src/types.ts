
export interface Book {
  id: string;
  title: string;
  chapter?: string;
  coverUrl: string;
  progress: number;
  category: string;
}

export interface ReadingStats {
  wordsRead: number;
  readingTime: number;
  weeklyMinutes: number;
  streakDays: number;
  badges: number;
  booksCompleted: number;
}

export type AppScreen = 'LOCK' | 'READING' | 'SUMMARY' | 'PARENT_DASHBOARD';
