import { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Textarea } from '../../components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../../components/ui/dialog';
import { Badge } from '../../components/ui/badge';
import { Plus, Pencil, Trash2, CheckCircle, Clock, MapPin } from 'lucide-react';
import { toast } from 'sonner';
import type { Talk } from '../../types';

export function SpeakerTalks() {
  const { user } = useAuth();
  const { talks, sections, addTalk, updateTalk, deleteTalk, tasks } = useData();
  const [open, setOpen] = useState(false);
  const [editingTalk, setEditingTalk] = useState<Talk | null>(null);
  
  const myTalks = talks.filter(t => t.speaker_id === user?.id);
  const myTasks = tasks.filter(t => t.assigned_to === user?.id);

  const [formData, setFormData] = useState({
    section_id: '',
    title: '',
    description: '',
    start_time: '',
    duration: '60',
    room: '',
  });

  const resetForm = () => {
    setFormData({
      section_id: '',
      title: '',
      description: '',
      start_time: '',
      duration: '60',
      room: '',
    });
    setEditingTalk(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (editingTalk) {
      updateTalk(editingTalk.id, {
        ...formData,
        duration: parseInt(formData.duration),
      });
      toast.success('Доклад обновлен');
    } else {
      addTalk({
        ...formData,
        speaker_id: user!.id,
        duration: parseInt(formData.duration),
        status: 'draft',
      });
      toast.success('Доклад создан');
    }
    
    setOpen(false);
    resetForm();
  };

  const handleEdit = (talk: Talk) => {
    setEditingTalk(talk);
    setFormData({
      section_id: talk.section_id,
      title: talk.title,
      description: talk.description,
      start_time: talk.start_time,
      duration: talk.duration.toString(),
      room: talk.room || '',
    });
    setOpen(true);
  };

  const handleDelete = (id: string) => {
    if (confirm('Вы уверены, что хотите удалить этот доклад?')) {
      deleteTalk(id);
      toast.success('Доклад удален');
    }
  };

  const markAsReady = (id: string) => {
    updateTalk(id, { status: 'ready' });
    toast.success('Доклад отмечен как готовый');
  };

  const formatTime = (dateString: string) => {
    return new Date(dateString).toLocaleTimeString('ru-RU', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ru-RU', { 
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold mb-2">Мои доклады</h1>
          <p className="text-muted-foreground">
            Управляйте своими выступлениями
          </p>
        </div>
        
        <Dialog open={open} onOpenChange={(isOpen) => {
          setOpen(isOpen);
          if (!isOpen) resetForm();
        }}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="size-4 mr-2" />
              Новый доклад
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>
                {editingTalk ? 'Редактировать доклад' : 'Новый доклад'}
              </DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <Label htmlFor="section">Секция</Label>
                <Select
                  value={formData.section_id}
                  onValueChange={(value) => {
                    const section = sections.find(s => s.id === value);
                    setFormData({ 
                      ...formData, 
                      section_id: value,
                      room: section?.room || '',
                    });
                  }}
                  required
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Выберите секцию" />
                  </SelectTrigger>
                  <SelectContent>
                    {sections.map((section) => (
                      <SelectItem key={section.id} value={section.id}>
                        {section.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              
              <div>
                <Label htmlFor="title">Название доклада</Label>
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
                  rows={4}
                />
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <Label htmlFor="start_time">Дата и время</Label>
                  <Input
                    id="start_time"
                    type="datetime-local"
                    value={formData.start_time}
                    onChange={(e) => setFormData({ ...formData, start_time: e.target.value })}
                    required
                  />
                </div>

                <div>
                  <Label htmlFor="duration">Длительность (мин)</Label>
                  <Input
                    id="duration"
                    type="number"
                    value={formData.duration}
                    onChange={(e) => setFormData({ ...formData, duration: e.target.value })}
                    required
                  />
                </div>

                <div>
                  <Label htmlFor="room">Зал</Label>
                  <Input
                    id="room"
                    value={formData.room}
                    onChange={(e) => setFormData({ ...formData, room: e.target.value })}
                  />
                </div>
              </div>

              <div className="flex gap-2 justify-end">
                <Button type="button" variant="outline" onClick={() => setOpen(false)}>
                  Отмена
                </Button>
                <Button type="submit">
                  {editingTalk ? 'Сохранить' : 'Создать'}
                </Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      {myTasks.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Мои задачи от организатора</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {myTasks.map((task) => (
                <div key={task.id} className="flex items-start gap-3 p-3 border rounded-lg">
                  <input
                    type="checkbox"
                    checked={task.completed}
                    readOnly
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
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      <div className="grid gap-4 md:grid-cols-2">
        {myTalks.length === 0 ? (
          <Card className="col-span-2">
            <CardContent className="py-16 text-center">
              <p className="text-muted-foreground">
                У вас пока нет докладов. Создайте свой первый доклад!
              </p>
            </CardContent>
          </Card>
        ) : (
          myTalks.map((talk) => {
            const section = sections.find(s => s.id === talk.section_id);
            
            return (
              <Card key={talk.id}>
                <CardHeader>
                  <CardTitle className="flex items-start justify-between">
                    <span className="flex-1">{talk.title}</span>
                    <Badge variant={talk.status === 'ready' ? 'default' : 'secondary'} className="ml-2">
                      {talk.status === 'ready' ? 'Готов' : 'Черновик'}
                    </Badge>
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {talk.description && (
                    <p className="text-sm text-muted-foreground">
                      {talk.description}
                    </p>
                  )}
                  
                  <div className="space-y-2 text-sm">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Users className="size-4" />
                      <span>{section?.name}</span>
                    </div>
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Clock className="size-4" />
                      <span>{formatDate(talk.start_time)}, {formatTime(talk.start_time)} ({talk.duration} мин)</span>
                    </div>
                    {talk.room && (
                      <div className="flex items-center gap-2 text-muted-foreground">
                        <MapPin className="size-4" />
                        <span>{talk.room}</span>
                      </div>
                    )}
                  </div>

                  <div className="flex gap-2 pt-2">
                    {talk.status !== 'ready' && (
                      <Button
                        variant="default"
                        size="sm"
                        onClick={() => markAsReady(talk.id)}
                        className="flex-1"
                      >
                        <CheckCircle className="size-4 mr-2" />
                        Отметить готовность
                      </Button>
                    )}
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleEdit(talk)}
                    >
                      <Pencil className="size-4" />
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleDelete(talk.id)}
                    >
                      <Trash2 className="size-4" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            );
          })
        )}
      </div>
    </div>
  );
}
