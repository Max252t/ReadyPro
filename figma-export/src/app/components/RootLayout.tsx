import { Outlet, Link, useNavigate } from 'react-router';
import { useAuth } from '../context/AuthContext';
import { Button } from './ui/button';
import { 
  LayoutDashboard, 
  Calendar, 
  CheckSquare, 
  Users, 
  Presentation, 
  FileText, 
  UserCircle,
  LogOut,
  Menu,
} from 'lucide-react';
import { useEffect, useState } from 'react';
import { Sheet, SheetContent, SheetTrigger } from './ui/sheet';
import { UserAvatar } from './UserAvatar';

export function RootLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (!user) {
      navigate('/login');
    }
  }, [user, navigate]);

  if (!user) {
    return null;
  }

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getNavigationLinks = () => {
    switch (user.role) {
      case 'organizer':
        return [
          { to: '/organizer/dashboard', icon: LayoutDashboard, label: 'Дашборд' },
          { to: '/organizer/sections', icon: Users, label: 'Секции' },
          { to: '/organizer/tasks', icon: CheckSquare, label: 'Задачи' },
          { to: '/organizer/schedule', icon: Calendar, label: 'Программа' },
          { to: '/participant/program', icon: Presentation, label: 'Расписание' },
        ];
      case 'curator':
        return [
          { to: '/curator/dashboard', icon: LayoutDashboard, label: 'Дашборд' },
          { to: '/curator/reports', icon: FileText, label: 'Отчеты' },
          { to: '/participant/program', icon: Presentation, label: 'Программа' },
        ];
      case 'speaker':
        return [
          { to: '/speaker/talks', icon: Presentation, label: 'Мои доклады' },
          { to: '/participant/program', icon: Calendar, label: 'Программа' },
        ];
      case 'participant':
        return [
          { to: '/participant/program', icon: Presentation, label: 'Программа' },
          { to: '/participant/schedule', icon: Calendar, label: 'Моё расписание' },
        ];
      default:
        return [];
    }
  };

  const navLinks = getNavigationLinks();

  const NavContent = () => (
    <>
      <div className="p-6 border-b">
        <h2 className="font-semibold text-lg">Хакатон 2026</h2>
        <div className="flex items-center gap-2 mt-2">
          <UserAvatar role={user.role} size="md" />
          <div>
            <p className="text-sm font-medium">{user.name}</p>
            <p className="text-xs text-muted-foreground capitalize">
              {user.role === 'organizer' && 'Организатор'}
              {user.role === 'curator' && 'Куратор'}
              {user.role === 'speaker' && 'Спикер'}
              {user.role === 'participant' && 'Участник'}
            </p>
          </div>
        </div>
      </div>
      
      <nav className="flex-1 p-4">
        <div className="space-y-1">
          {navLinks.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              onClick={() => setOpen(false)}
              className="flex items-center gap-3 px-3 py-2 rounded-md hover:bg-accent transition-colors"
            >
              <link.icon className="size-5" />
              <span>{link.label}</span>
            </Link>
          ))}
        </div>
      </nav>

      <div className="p-4 border-t space-y-2">
        <Link
          to="/profile"
          onClick={() => setOpen(false)}
          className="flex items-center gap-3 px-3 py-2 rounded-md hover:bg-accent transition-colors w-full"
        >
          <UserCircle className="size-5" />
          <span>Профиль</span>
        </Link>
        <Button
          variant="ghost"
          onClick={handleLogout}
          className="w-full justify-start"
        >
          <LogOut className="size-5 mr-3" />
          Выйти
        </Button>
      </div>
    </>
  );

  return (
    <div className="flex min-h-screen">
      {/* Desktop sidebar */}
      <aside className="hidden md:flex md:w-64 border-r bg-card flex-col">
        <NavContent />
      </aside>

      {/* Mobile header */}
      <div className="md:hidden fixed top-0 left-0 right-0 h-16 border-b bg-card z-50 flex items-center px-4">
        <Sheet open={open} onOpenChange={setOpen}>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon">
              <Menu className="size-6" />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="p-0 w-64">
            <div className="flex flex-col h-full">
              <NavContent />
            </div>
          </SheetContent>
        </Sheet>
        <h1 className="ml-4 font-semibold">Хакатон 2026</h1>
      </div>

      {/* Main content */}
      <main className="flex-1 md:p-8 p-4 md:mt-0 mt-16">
        <Outlet />
      </main>
    </div>
  );
}