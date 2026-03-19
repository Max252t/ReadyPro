import { createBrowserRouter, Navigate } from 'react-router';
import { RootLayout } from './components/RootLayout';
import { LoginPage } from './pages/LoginPage';
import { OrganizerDashboard } from './pages/organizer/OrganizerDashboard';
import { SectionsPage } from './pages/organizer/SectionsPage';
import { TasksPage } from './pages/organizer/TasksPage';
import { SchedulePage } from './pages/organizer/SchedulePage';
import { CuratorDashboard } from './pages/curator/CuratorDashboard';
import { CuratorReports } from './pages/curator/CuratorReports';
import { SpeakerTalks } from './pages/speaker/SpeakerTalks';
import { ProgramPage } from './pages/participant/ProgramPage';
import { MySchedulePage } from './pages/participant/MySchedulePage';
import { TalkDetailsPage } from './pages/TalkDetailsPage';
import { ProfilePage } from './pages/ProfilePage';

export const router = createBrowserRouter([
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/',
    element: <RootLayout />,
    children: [
      {
        index: true,
        element: <Navigate to="/dashboard" replace />,
      },
      {
        path: 'dashboard',
        element: <Navigate to="/organizer/dashboard" replace />,
      },
      // Organizer routes
      {
        path: 'organizer/dashboard',
        element: <OrganizerDashboard />,
      },
      {
        path: 'organizer/sections',
        element: <SectionsPage />,
      },
      {
        path: 'organizer/tasks',
        element: <TasksPage />,
      },
      {
        path: 'organizer/schedule',
        element: <SchedulePage />,
      },
      // Curator routes
      {
        path: 'curator/dashboard',
        element: <CuratorDashboard />,
      },
      {
        path: 'curator/reports',
        element: <CuratorReports />,
      },
      // Speaker routes
      {
        path: 'speaker/talks',
        element: <SpeakerTalks />,
      },
      // Participant routes
      {
        path: 'participant/program',
        element: <ProgramPage />,
      },
      {
        path: 'participant/schedule',
        element: <MySchedulePage />,
      },
      // Common routes
      {
        path: 'talk/:id',
        element: <TalkDetailsPage />,
      },
      {
        path: 'profile',
        element: <ProfilePage />,
      },
    ],
  },
]);
