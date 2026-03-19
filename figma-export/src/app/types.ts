// Типы данных для системы управления мероприятиями

export type UserRole = 'organizer' | 'curator' | 'speaker' | 'participant';

export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  avatar?: string;
}

export interface Event {
  id: string;
  name: string;
  description: string;
  start_date: string;
  end_date: string;
  status: 'planning' | 'ongoing' | 'completed';
}

export interface Section {
  id: string;
  event_id: string;
  name: string;
  description: string;
  curator_id?: string;
  room?: string;
}

export interface Talk {
  id: string;
  section_id: string;
  speaker_id: string;
  title: string;
  description: string;
  start_time: string;
  duration: number; // в минутах
  room?: string;
  status: 'draft' | 'ready' | 'ongoing' | 'completed';
}

export interface Task {
  id: string;
  event_id: string;
  assigned_to: string; // user_id
  created_by: string; // user_id
  title: string;
  description: string;
  completed: boolean;
  due_date?: string;
}

export interface Schedule {
  id: string;
  user_id: string;
  talk_id: string;
  created_at: string;
}

export interface Feedback {
  id: string;
  talk_id: string;
  user_id: string;
  rating: number; // 1-5
  comment: string;
  created_at: string;
}

export interface Comment {
  id: string;
  talk_id: string;
  user_id: string;
  message: string;
  created_at: string;
  reply_to?: string; // comment_id
}

export interface CuratorReport {
  id: string;
  section_id: string;
  curator_id: string;
  report_text: string;
  created_at: string;
}
