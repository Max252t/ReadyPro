import { useAuth } from '../context/AuthContext';
import { useData } from '../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Badge } from '../components/ui/badge';
import { Checkbox } from '../components/ui/checkbox';
import { Separator } from '../components/ui/separator';
import { UserCircle, Mail, Briefcase, CheckSquare } from 'lucide-react';
import { UserAvatar } from '../components/UserAvatar';
import { ThemeToggle } from '../components/ThemeToggle';

export function ProfilePage() {
  const { user } = useAuth();
  const { tasks, talks, sections } = useData();
  
  const myTasks = tasks.filter(t => t.assigned_to === user?.id);
  const myTalks = talks.filter(t => t.speaker_id === user?.id);
  const mySections = sections.filter(s => s.curator_id === user?.id);

  const getRoleLabel = (role: string) => {
    switch (role) {
      case 'organizer': return 'Организатор';
      case 'curator': return 'Куратор';
      case 'speaker': return 'Спикер';
      case 'participant': return 'Участник';
      default: return role;
    }
  };

  return (
    <div className="max-w-4xl space-y-6">
      <header className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold mb-2">Профиль</h1>
          <p className="text-muted-foreground">
            Ваша информация и активность
          </p>
        </div>
        <div className="flex items-center gap-2 sm:pt-1">
          <span className="text-sm text-muted-foreground whitespace-nowrap">Тема оформления</span>
          <ThemeToggle />
        </div>
      </header>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <UserCircle className="size-6" />
            Основная информация
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center">
              <UserAvatar role={user?.role || 'participant'} size="lg" className="text-primary" />
            </div>
            <div className="flex-1">
              <h2 className="text-2xl font-semibold">{user?.name}</h2>
              <div className="flex items-center gap-2 mt-1 text-muted-foreground">
                <Mail className="size-4" />
                <span>{user?.email}</span>
              </div>
              <div className="flex items-center gap-2 mt-1">
                <Briefcase className="size-4" />
                <Badge>{getRoleLabel(user?.role || '')}</Badge>
              </div>
            </div>
          </div>

          <Separator />

          <div className="grid grid-cols-3 gap-4 text-center">
            <div className="p-4 bg-muted rounded-lg">
              <p className="text-2xl font-semibold">{myTasks.length}</p>
              <p className="text-sm text-muted-foreground mt-1">Задач</p>
            </div>
            {user?.role === 'speaker' && (
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-2xl font-semibold">{myTalks.length}</p>
                <p className="text-sm text-muted-foreground mt-1">Докладов</p>
              </div>
            )}
            {user?.role === 'curator' && (
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-2xl font-semibold">{mySections.length}</p>
                <p className="text-sm text-muted-foreground mt-1">Секций</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {myTasks.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <CheckSquare className="size-5" />
              Мои задачи
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {myTasks.map((task) => (
                <div key={task.id} className="flex gap-3 p-3 border rounded-lg">
                  <Checkbox checked={task.completed} className="mt-1" />
                  <div className="flex-1">
                    <p className={task.completed ? 'line-through text-muted-foreground' : 'font-medium'}>
                      {task.title}
                    </p>
                    {task.description && (
                      <p className="text-sm text-muted-foreground mt-1">
                        {task.description}
                      </p>
                    )}
                    {task.due_date && (
                      <p className="text-xs text-muted-foreground mt-2">
                        Срок: {new Date(task.due_date).toLocaleDateString('ru-RU')}
                      </p>
                    )}
                  </div>
                  <Badge variant={task.completed ? 'default' : 'secondary'}>
                    {task.completed ? 'Выполнено' : 'В работе'}
                  </Badge>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {user?.role === 'speaker' && myTalks.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Мои доклады</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {myTalks.map((talk) => {
                const section = sections.find(s => s.id === talk.section_id);
                
                return (
                  <div key={talk.id} className="p-3 border rounded-lg">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <p className="font-medium">{talk.title}</p>
                        <p className="text-sm text-muted-foreground mt-1">
                          {section?.name} • {new Date(talk.start_time).toLocaleDateString('ru-RU')}
                        </p>
                      </div>
                      <Badge variant={talk.status === 'ready' ? 'default' : 'secondary'}>
                        {talk.status === 'ready' ? 'Готов' : 'Черновик'}
                      </Badge>
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      )}

      {user?.role === 'curator' && mySections.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Мои секции</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {mySections.map((section) => {
                const sectionTalks = talks.filter(t => t.section_id === section.id);
                
                return (
                  <div key={section.id} className="p-3 border rounded-lg">
                    <p className="font-medium">{section.name}</p>
                    <p className="text-sm text-muted-foreground mt-1">
                      {section.room || 'Зал не указан'} • {sectionTalks.length} докладов
                    </p>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}