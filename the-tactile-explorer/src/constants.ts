import { Book, ReadingStats } from './types';

export const BOOKS: Book[] = [
  {
    id: '1',
    title: 'The Brave Little Star',
    chapter: 'Chapter 3: The Moon\'s Hidden Path',
    coverUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAxV38iaiqFdeqQSiRy4kWo3_kIq9JvRRCwrBCGGmkDKev38c61PgcLLCK6G-XppBgUWdSUgY9h9H7KAxoNGEcVLMMxzpXzbVqpeJtRPSeyeG7mAMEPJ9Tn9JhDBXwWjYIwJadg_KFR6tEUlJYycsQ1q0P9Vv1_L5bvBl2OXHViLsoCfvpSghPO_cUPussiRcSDMsbFHBHeqDBzGJc5i4_ml87tAzBI3X8FX-Jp_hgx4ScRYKT3NmHijcFzL-V7MJKGeg_-E2g9e1s',
    progress: 75,
    category: 'Adventure'
  },
  {
    id: '2',
    title: 'The Brave Little Toaster',
    coverUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCRvhGxEj1VNbOpTPn5xfhsPtB9mks84GmsT7DD_ah4OR0fP6GoyVEG_coffa-qVI_i9dzw54_ZiCfJSPJFgTn5HYZT1474tetrRmLT8VRlRORaFuXuuRvjAa5TUeloRLfJa_Dua18zeJCiX4UDZYVaI_bQ9NojR5rmMs4NlLLZ2ly2zHU8GrGWkUf3_emtM50fUX4aakJ5d2QQ1RBq0DgzhsoV0NJfPCzg6URW7Ql0v5FMBangtwxfwFpuRVbDUF_3K3k-_MF4ZXE',
    progress: 85,
    category: 'Adventure'
  },
  {
    id: '3',
    title: 'Cloudy with a Chance',
    coverUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjNh_PYeMVpKCBASaGqnqTZt8Xif6P0FA9lr81n0-I-UMGkL9lHYE3kGI8Y8d9EQpqdretPrjp42csYKfnwCxbz0HwrzhD0ar5UqCCVWVo0sui-HaCiVgqHXwy0uRA7TvsyWIV070FXsOUY75avMubTABJzo0CUuWNcnS02pvxH5KtLHh8u_xuHeiTwYx2bruh0HS5gCKoCT_8B-OwhQYX3cU6TqQOL5OHyTphill0sePattYvMXPzWU8ZQ1bOARIfy8Jkr2wWUOU',
    progress: 12,
    category: 'Fantasy'
  }
];

export const MOCK_STATS: ReadingStats = {
  wordsRead: 412,
  readingTime: 15,
  weeklyMinutes: 124,
  streakDays: 5,
  badges: 12,
  booksCompleted: 4
};

export const WEEKLY_PROGRESS = [
  { day: 'MON', minutes: 45, color: 'primary' },
  { day: 'TUE', minutes: 65, color: 'primary' },
  { day: 'WED', minutes: 80, color: 'tertiary' },
  { day: 'THU', minutes: 35, color: 'primary' },
  { day: 'FRI', minutes: 55, color: 'primary-container' },
  { day: 'SAT', minutes: 0, color: 'surface-variant' },
  { day: 'SUN', minutes: 0, color: 'surface-variant' },
];
