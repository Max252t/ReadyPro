import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Progress } from '../../components/ui/progress';
import { Users, CheckSquare, Calendar, TrendingUp } from 'lucide-react';

export function OrganizerDashboard() {
  const { events, sections, tasks, talks } = useData();
  
  const currentEvent = events[0];
  const completedTasks = tasks.filter(t => t.completed).length;
  const totalTasks = tasks.length;
  const progressPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  
  const readyTalks = talks.filter(t => t.status === 'ready').length;
  const totalTalks = talks.length;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold mb-2">Дашборд организатора</h1>
        <p className="text-muted-foreground">
          {currentEvent.name}
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Общий прогресс</CardTitle>
            <TrendingUp className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{Math.round(progressPercentage)}%</div>
            <Progress value={progressPercentage} className="mt-2" />
            <p className="text-xs text-muted-foreground mt-2">
              {completedTasks} из {totalTasks} задач выполнено
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Секции</CardTitle>
            <Users className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{sections.length}</div>
            <p className="text-xs text-muted-foreground mt-2">
              {sections.filter(s => s.curator_id).length} с кураторами
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Задачи</CardTitle>
            <CheckSquare className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{totalTasks}</div>
            <p className="text-xs text-muted-foreground mt-2">
              {tasks.filter(t => !t.completed).length} активных
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Доклады</CardTitle>
            <Calendar className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">{totalTalks}</div>
            <p className="text-xs text-muted-foreground mt-2">
              {readyTalks} готовы
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Последние задачи</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {tasks.slice(0, 5).map((task) => (
                <div key={task.id} className="flex items-start gap-3">
                  <input
                    type="checkbox"
                    checked={task.completed}
                    readOnly
                    className="mt-1"
                  />
                  <div className="flex-1">
                    <p className={task.completed ? 'line-through text-muted-foreground' : ''}>
                      {task.title}
                    </p>
                    {task.due_date && (
                      <p className="text-xs text-muted-foreground">
                        Срок: {new Date(task.due_date).toLocaleDateString('ru-RU')}
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Секции мероприятия</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {sections.map((section) => (
                <div key={section.id} className="border-l-4 border-primary pl-3">
                  <p className="font-medium">{section.name}</p>
                  <p className="text-sm text-muted-foreground">
                    {section.room || 'Зал не указан'}
                    {section.curator_id && ' • Куратор назначен'}
                  </p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
