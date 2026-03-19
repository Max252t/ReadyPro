import { useState } from 'react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Textarea } from '../../components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../../components/ui/dialog';
import { Checkbox } from '../../components/ui/checkbox';
import { Plus, Calendar } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../../mock-data';
import { UserDisplay } from '../../components/UserDisplay';

export function TasksPage() {
  const { tasks, addTask, updateTask, events } = useData();
  const { user } = useAuth();
  const [open, setOpen] = useState(false);
  
  const assignableUsers = mockUsers.filter(u => ['curator', 'speaker'].includes(u.role));
  const currentEvent = events[0];

  const [formData, setFormData] = useState({
    assigned_to: '',
    title: '',
    description: '',
    due_date: '',
  });

  const resetForm = () => {
    setFormData({
      assigned_to: '',
      title: '',
      description: '',
      due_date: '',
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    addTask({
      ...formData,
      event_id: currentEvent.id,
      created_by: user!.id,
      completed: false,
    });
    
    toast.success('Задача создана');
    setOpen(false);
    resetForm();
  };

  const toggleTask = (taskId: string, completed: boolean) => {
    updateTask(taskId, { completed });
    toast.success(completed ? 'Задача выполнена' : 'Задача возвращена в работу');
  };

  const activeTasks = tasks.filter(t => !t.completed);
  const completedTasks = tasks.filter(t => t.completed);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold">Управление задачами</h1>
          <p className="text-muted-foreground mt-1">
            Создавайте и отслеживайте задачи для команды
          </p>
        </div>
        
        <Dialog open={open} onOpenChange={(isOpen) => {
          setOpen(isOpen);
          if (!isOpen) resetForm();
        }}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="size-4 mr-2" />
              Новая задача
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Создать задачу</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <Label htmlFor="assigned_to">Назначить</Label>
                <Select
                  value={formData.assigned_to}
                  onValueChange={(value) => setFormData({ ...formData, assigned_to: value })}
                  required
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Выберите исполнителя" />
                  </SelectTrigger>
                  <SelectContent>
                    {assignableUsers.map((usr) => (
                      <SelectItem key={usr.id} value={usr.id}>
                        {usr.name} ({usr.role === 'curator' ? 'Куратор' : 'Спикер'})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              
              <div>
                <Label htmlFor="title">Название задачи</Label>
                <Input
                  id="title"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  required
                />
              </div>
              
              <div>
                <Label htmlFor="description">Описание</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={3}
                />
              </div>

              <div>
                <Label htmlFor="due_date">Срок выполнения</Label>
                <Input
                  id="due_date"
                  type="date"
                  value={formData.due_date}
                  onChange={(e) => setFormData({ ...formData, due_date: e.target.value })}
                />
              </div>

              <div className="flex gap-2 justify-end">
                <Button type="button" variant="outline" onClick={() => setOpen(false)}>
                  Отмена
                </Button>
                <Button type="submit">Создать</Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Активные задачи ({activeTasks.length})</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {activeTasks.length === 0 ? (
                <p className="text-muted-foreground text-center py-8">
                  Нет активных задач
                </p>
              ) : (
                activeTasks.map((task) => {
                  const assignedUser = assignableUsers.find(u => u.id === task.assigned_to);
                  
                  return (
                    <div key={task.id} className="flex gap-3 p-3 border rounded-lg">
                      <Checkbox
                        checked={task.completed}
                        onCheckedChange={(checked) => toggleTask(task.id, checked as boolean)}
                        className="mt-1"
                      />
                      <div className="flex-1">
                        <p className="font-medium">{task.title}</p>
                        {task.description && (
                          <p className="text-sm text-muted-foreground mt-1">
                            {task.description}
                          </p>
                        )}
                        <div className="flex items-center gap-3 mt-2 text-xs text-muted-foreground">
                          {assignedUser && (
                            <UserDisplay user={assignedUser} size="sm" />
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Выполненные задачи ({completedTasks.length})</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {completedTasks.length === 0 ? (
                <p className="text-muted-foreground text-center py-8">
                  Нет выполненных задач
                </p>
              ) : (
                completedTasks.map((task) => {
                  const assignedUser = assignableUsers.find(u => u.id === task.assigned_to);
                  
                  return (
                    <div key={task.id} className="flex gap-3 p-3 border rounded-lg bg-muted/30">
                      <Checkbox
                        checked={task.completed}
                        onCheckedChange={(checked) => toggleTask(task.id, checked as boolean)}
                        className="mt-1"
                      />
                      <div className="flex-1">
                        <p className="font-medium line-through text-muted-foreground">
                          {task.title}
                        </p>
                        {task.description && (
                          <p className="text-sm text-muted-foreground mt-1">
                            {task.description}
                          </p>
                        )}
                        <div className="flex items-center gap-3 mt-2 text-xs text-muted-foreground">
                          {assignedUser && (
                            <UserDisplay user={assignedUser} size="sm" />
                          )}
                        </div>
                      </div>
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