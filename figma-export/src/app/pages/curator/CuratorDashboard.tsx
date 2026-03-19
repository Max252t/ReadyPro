import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Checkbox } from '../../components/ui/checkbox';
import { Badge } from '../../components/ui/badge';
import { Users, CheckSquare, MessageSquare } from 'lucide-react';

export function CuratorDashboard() {
  const { user } = useAuth();
  const { sections, talks, tasks, updateTask, comments } = useData();
  
  const mySections = sections.filter(s => s.curator_id === user?.id);
  const myTasks = tasks.filter(t => t.assigned_to === user?.id);
  const activeTasks = myTasks.filter(t => !t.completed);
  
  const myTalks = talks.filter(t => 
    mySections.some(s => s.id === t.section_id)
  );
  
  const myComments = comments.filter(c => 
    myTalks.some(t => t.id === c.talk_id)
  );

  const toggleTask = (taskId: string, completed: boolean) => {
    updateTask(taskId, { completed });
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold mb-2">Дашборд куратора</h1>
        <p className="text-muted-foreground">
          Управление вашими секциями и задачами
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Мои секции</CardTitle>
            <Users className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{mySections.length}</div>
            <p className="text-xs text-muted-foreground mt-2">
              {myTalks.length} докладов
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Задачи</CardTitle>
            <CheckSquare className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{myTasks.length}</div>
            <p className="text-xs text-muted-foreground mt-2">
              {activeTasks.length} активных
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Вопросы</CardTitle>
            <MessageSquare className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{myComments.length}</div>
            <p className="text-xs text-muted-foreground mt-2">
              к вашим секциям
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Мои задачи</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {myTasks.length === 0 ? (
                <p className="text-muted-foreground text-center py-8">
                  Нет назначенных задач
                </p>
              ) : (
                myTasks.map((task) => (
                  <div key={task.id} className="flex gap-3 p-3 border rounded-lg">
                    <Checkbox
                      checked={task.completed}
                      onCheckedChange={(checked) => toggleTask(task.id, checked as boolean)}
                      className="mt-1"
                    />
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
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Доклады моих секций</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {myTalks.length === 0 ? (
                <p className="text-muted-foreground text-center py-8">
                  Доклады не добавлены
                </p>
              ) : (
                myTalks.map((talk) => {
                  const section = mySections.find(s => s.id === talk.section_id);
                  
                  return (
                    <div key={talk.id} className="border-l-4 border-primary pl-3">
                      <div className="flex items-start justify-between mb-1">
                        <p className="font-medium">{talk.title}</p>
                        <Badge variant={talk.status === 'ready' ? 'default' : 'secondary'} className="ml-2">
                          {talk.status === 'ready' ? 'Готов' : 'Черновик'}
                        </Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">
                        {section?.name} • {new Date(talk.start_time).toLocaleTimeString('ru-RU', { 
                          hour: '2-digit', 
                          minute: '2-digit' 
                        })}
                      </p>
                    </div>
                  );
                })
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
