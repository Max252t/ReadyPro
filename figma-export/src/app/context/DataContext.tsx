import React, { createContext, useContext, useState } from 'react';
import type { Event, Section, Talk, Task, Schedule, Feedback, Comment, CuratorReport } from '../types';
import {
  mockEvents,
  mockSections,
  mockTalks,
  mockTasks,
  mockSchedule,
  mockFeedback,
  mockComments,
  mockReports,
} from '../mock-data';

interface DataContextType {
  events: Event[];
  sections: Section[];
  talks: Talk[];
  tasks: Task[];
  schedule: Schedule[];
  feedback: Feedback[];
  comments: Comment[];
  reports: CuratorReport[];
  
  // CRUD операции
  addSection: (section: Omit<Section, 'id'>) => void;
  updateSection: (id: string, section: Partial<Section>) => void;
  deleteSection: (id: string) => void;
  
  addTalk: (talk: Omit<Talk, 'id'>) => void;
  updateTalk: (id: string, talk: Partial<Talk>) => void;
  deleteTalk: (id: string) => void;
  
  addTask: (task: Omit<Task, 'id'>) => void;
  updateTask: (id: string, task: Partial<Task>) => void;
  deleteTask: (id: string) => void;
  
  addToSchedule: (userId: string, talkId: string) => void;
  removeFromSchedule: (userId: string, talkId: string) => void;
  
  addFeedback: (feedback: Omit<Feedback, 'id' | 'created_at'>) => void;
  
  addComment: (comment: Omit<Comment, 'id' | 'created_at'>) => void;
  
  addReport: (report: Omit<CuratorReport, 'id' | 'created_at'>) => void;
  updateReport: (id: string, report: Partial<CuratorReport>) => void;
}

const DataContext = createContext<DataContextType | undefined>(undefined);

export function DataProvider({ children }: { children: React.ReactNode }) {
  const [events] = useState<Event[]>(mockEvents);
  const [sections, setSections] = useState<Section[]>(mockSections);
  const [talks, setTalks] = useState<Talk[]>(mockTalks);
  const [tasks, setTasks] = useState<Task[]>(mockTasks);
  const [schedule, setSchedule] = useState<Schedule[]>(mockSchedule);
  const [feedback, setFeedback] = useState<Feedback[]>(mockFeedback);
  const [comments, setComments] = useState<Comment[]>(mockComments);
  const [reports, setReports] = useState<CuratorReport[]>(mockReports);

  // Sections CRUD
  const addSection = (section: Omit<Section, 'id'>) => {
    const newSection = { ...section, id: `sec${Date.now()}` };
    setSections([...sections, newSection]);
  };

  const updateSection = (id: string, section: Partial<Section>) => {
    setSections(sections.map(s => s.id === id ? { ...s, ...section } : s));
  };

  const deleteSection = (id: string) => {
    setSections(sections.filter(s => s.id !== id));
  };

  // Talks CRUD
  const addTalk = (talk: Omit<Talk, 'id'>) => {
    const newTalk = { ...talk, id: `talk${Date.now()}` };
    setTalks([...talks, newTalk]);
  };

  const updateTalk = (id: string, talk: Partial<Talk>) => {
    setTalks(talks.map(t => t.id === id ? { ...t, ...talk } : t));
  };

  const deleteTalk = (id: string) => {
    setTalks(talks.filter(t => t.id !== id));
  };

  // Tasks CRUD
  const addTask = (task: Omit<Task, 'id'>) => {
    const newTask = { ...task, id: `task${Date.now()}` };
    setTasks([...tasks, newTask]);
  };

  const updateTask = (id: string, task: Partial<Task>) => {
    setTasks(tasks.map(t => t.id === id ? { ...t, ...task } : t));
  };

  const deleteTask = (id: string) => {
    setTasks(tasks.filter(t => t.id !== id));
  };

  // Schedule
  const addToSchedule = (userId: string, talkId: string) => {
    const newScheduleItem = {
      id: `sch${Date.now()}`,
      user_id: userId,
      talk_id: talkId,
      created_at: new Date().toISOString(),
    };
    setSchedule([...schedule, newScheduleItem]);
  };

  const removeFromSchedule = (userId: string, talkId: string) => {
    setSchedule(schedule.filter(s => !(s.user_id === userId && s.talk_id === talkId)));
  };

  // Feedback
  const addFeedback = (fb: Omit<Feedback, 'id' | 'created_at'>) => {
    const newFeedback = {
      ...fb,
      id: `fb${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    setFeedback([...feedback, newFeedback]);
  };

  // Comments
  const addComment = (cmt: Omit<Comment, 'id' | 'created_at'>) => {
    const newComment = {
      ...cmt,
      id: `cmt${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    setComments([...comments, newComment]);
  };

  // Reports
  const addReport = (report: Omit<CuratorReport, 'id' | 'created_at'>) => {
    const newReport = {
      ...report,
      id: `rep${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    setReports([...reports, newReport]);
  };

  const updateReport = (id: string, report: Partial<CuratorReport>) => {
    setReports(reports.map(r => r.id === id ? { ...r, ...report } : r));
  };

  return (
    <DataContext.Provider
      value={{
        events,
        sections,
        talks,
        tasks,
        schedule,
        feedback,
        comments,
        reports,
        addSection,
        updateSection,
        deleteSection,
        addTalk,
        updateTalk,
        deleteTalk,
        addTask,
        updateTask,
        deleteTask,
        addToSchedule,
        removeFromSchedule,
        addFeedback,
        addComment,
        addReport,
        updateReport,
      }}
    >
      {children}
    </DataContext.Provider>
  );
}

export function useData() {
  const context = useContext(DataContext);
  if (!context) {
    throw new Error('useData must be used within DataProvider');
  }
  return context;
}
