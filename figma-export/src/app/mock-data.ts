// Mock данные для демонстрации функционала
import type { User, Event, Section, Talk, Task, Schedule, Feedback, Comment, CuratorReport } from './types';

export const mockUsers: User[] = [
  { id: '1', email: 'organizer@event.com', name: 'Алексей Иванов', role: 'organizer' },
  { id: '2', email: 'curator1@event.com', name: 'Мария Петрова', role: 'curator' },
  { id: '3', email: 'curator2@event.com', name: 'Дмитрий Сидоров', role: 'curator' },
  { id: '4', email: 'speaker1@event.com', name: 'Анна Козлова', role: 'speaker' },
  { id: '5', email: 'speaker2@event.com', name: 'Павел Новиков', role: 'speaker' },
  { id: '6', email: 'speaker3@event.com', name: 'Елена Смирнова', role: 'speaker' },
  { id: '7', email: 'participant1@event.com', name: 'Иван Волков', role: 'participant' },
  { id: '8', email: 'participant2@event.com', name: 'Ольга Морозова', role: 'participant' },
];

export const mockEvents: Event[] = [
  {
    id: 'evt1',
    name: 'Технологический хакатон 2026',
    description: 'Трехдневный хакатон по разработке инновационных решений',
    start_date: '2026-04-10',
    end_date: '2026-04-12',
    status: 'planning',
  },
];

export const mockSections: Section[] = [
  {
    id: 'sec1',
    event_id: 'evt1',
    name: 'Искусственный интеллект',
    description: 'Секция посвященная ИИ и машинному обучению',
    curator_id: '2',
    room: 'Зал А',
  },
  {
    id: 'sec2',
    event_id: 'evt1',
    name: 'Блокчейн и Web3',
    description: 'Секция о децентрализованных технологиях',
    curator_id: '3',
    room: 'Зал Б',
  },
  {
    id: 'sec3',
    event_id: 'evt1',
    name: 'Кибербезопасность',
    description: 'Секция о защите информации',
    room: 'Зал В',
  },
];

export const mockTalks: Talk[] = [
  {
    id: 'talk1',
    section_id: 'sec1',
    speaker_id: '4',
    title: 'Введение в нейронные сети',
    description: 'Базовые концепции и практическое применение',
    start_time: '2026-04-10T10:00:00',
    duration: 60,
    room: 'Зал А',
    status: 'ready',
  },
  {
    id: 'talk2',
    section_id: 'sec1',
    speaker_id: '5',
    title: 'LLM модели в производстве',
    description: 'Опыт внедрения больших языковых моделей',
    start_time: '2026-04-10T11:30:00',
    duration: 45,
    room: 'Зал А',
    status: 'draft',
  },
  {
    id: 'talk3',
    section_id: 'sec2',
    speaker_id: '6',
    title: 'Смарт-контракты на практике',
    description: 'Разработка и деплой умных контрактов',
    start_time: '2026-04-10T10:00:00',
    duration: 90,
    room: 'Зал Б',
    status: 'ready',
  },
  {
    id: 'talk4',
    section_id: 'sec2',
    speaker_id: '4',
    title: 'DeFi экосистема',
    description: 'Обзор децентрализованных финансов',
    start_time: '2026-04-10T14:00:00',
    duration: 60,
    room: 'Зал Б',
    status: 'ready',
  },
];

export const mockTasks: Task[] = [
  {
    id: 'task1',
    event_id: 'evt1',
    assigned_to: '2',
    created_by: '1',
    title: 'Проверить презентации спикеров',
    description: 'Убедиться что все презентации загружены',
    completed: true,
    due_date: '2026-04-08',
  },
  {
    id: 'task2',
    event_id: 'evt1',
    assigned_to: '2',
    created_by: '1',
    title: 'Подготовить раздаточный материал',
    description: 'Распечатать программу секции для участников',
    completed: false,
    due_date: '2026-04-09',
  },
  {
    id: 'task3',
    event_id: 'evt1',
    assigned_to: '4',
    created_by: '1',
    title: 'Отправить презентацию',
    description: 'Загрузить финальную версию презентации',
    completed: false,
    due_date: '2026-04-09',
  },
  {
    id: 'task4',
    event_id: 'evt1',
    assigned_to: '3',
    created_by: '1',
    title: 'Проверить оборудование в зале',
    description: 'Убедиться что проектор и микрофоны работают',
    completed: false,
    due_date: '2026-04-09',
  },
];

export const mockSchedule: Schedule[] = [
  { id: 'sch1', user_id: '7', talk_id: 'talk1', created_at: '2026-03-15T10:00:00' },
  { id: 'sch2', user_id: '7', talk_id: 'talk3', created_at: '2026-03-15T10:05:00' },
  { id: 'sch3', user_id: '8', talk_id: 'talk1', created_at: '2026-03-16T14:00:00' },
  { id: 'sch4', user_id: '8', talk_id: 'talk4', created_at: '2026-03-16T14:05:00' },
];

export const mockFeedback: Feedback[] = [
  {
    id: 'fb1',
    talk_id: 'talk1',
    user_id: '7',
    rating: 5,
    comment: 'Отличный доклад! Очень понятно объяснили сложные концепции',
    created_at: '2026-04-10T11:00:00',
  },
  {
    id: 'fb2',
    talk_id: 'talk3',
    user_id: '7',
    rating: 4,
    comment: 'Интересно, но хотелось бы больше примеров кода',
    created_at: '2026-04-10T11:30:00',
  },
];

export const mockComments: Comment[] = [
  {
    id: 'cmt1',
    talk_id: 'talk1',
    user_id: '7',
    message: 'Какие фреймворки вы рекомендуете для начинающих?',
    created_at: '2026-04-10T10:30:00',
  },
  {
    id: 'cmt2',
    talk_id: 'talk1',
    user_id: '4',
    message: 'Я бы посоветовал начать с PyTorch или TensorFlow',
    created_at: '2026-04-10T10:32:00',
    reply_to: 'cmt1',
  },
  {
    id: 'cmt3',
    talk_id: 'talk1',
    user_id: '8',
    message: 'Можете посоветовать литературу по теме?',
    created_at: '2026-04-10T10:45:00',
  },
];

export const mockReports: CuratorReport[] = [
  {
    id: 'rep1',
    section_id: 'sec1',
    curator_id: '2',
    report_text: 'Секция прошла успешно. Все доклады начались вовремя. Участники активно задавали вопросы.',
    created_at: '2026-04-10T18:00:00',
  },
];