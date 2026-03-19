import { useState } from 'react';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Textarea } from '../../components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../../components/ui/dialog';
import { Badge } from '../../components/ui/badge';
import { Plus, Clock, MapPin } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../../mock-data';
import { UserDisplay } from '../../components/UserDisplay';

export function SchedulePage() {
  const { talks, sections, addTalk, updateTalk } = useData();
  const [open, setOpen] = useState(false);
  
  const speakers = mockUsers.filter(u => u.role === 'speaker');

  const [formData, setFormData] = useState({
    section_id: '',
    speaker_id: '',
    title: '',
    description: '',
    start_time: '',
    duration: '60',
    room: '',
  });

  const resetForm = () => {
    setFormData({
      section_id: '',
      speaker_id: '',
      title: '',
      description: '',
      start_time: '',
      duration: '60',
      room: '',
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    addTalk({
      ...formData,
      duration: parseInt(formData.duration),
      status: 'draft',
    });
    
    toast.success('Доклад добавлен в программу');
    setOpen(false);
    resetForm();
  };

  const groupedBySection = sections.map(section => ({
    section,
    talks: talks.filter(t => t.section_id === section.id)
      .sort((a, b) => new Date(a.start_time).getTime() - new Date(b.start_time).getTime()),
  }));

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
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold">Наполнение программы</h1>
          <p className="text-muted-foreground mt-1">
            Добавляйте доклады в расписание мероприятия
          </p>
        </div>
        
        <Dialog open={open} onOpenChange={(isOpen) => {
          setOpen(isOpen);
          if (!isOpen) resetForm();
        }}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="size-4 mr-2" />
              Добавить доклад
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Новый доклад</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
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
                  <Label htmlFor="speaker">Спикер</Label>
                  <Select
                    value={formData.speaker_id}
                    onValueChange={(value) => setFormData({ ...formData, speaker_id: value })}
                    required
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Выберите спикера" />
                    </SelectTrigger>
                    <SelectContent>
                      {speakers.map((speaker) => (
                        <SelectItem key={speaker.id} value={speaker.id}>
                          {speaker.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
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
                  rows={3}
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
                <Button type="submit">Добавить</Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <div className="space-y-6">
        {groupedBySection.map(({ section, talks: sectionTalks }) => (
          <Card key={section.id}>
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                <span>{section.name}</span>
                <Badge variant="outline">{sectionTalks.length} докладов</Badge>
              </CardTitle>
            </CardHeader>
            <CardContent>
              {sectionTalks.length === 0 ? (
                <p className="text-muted-foreground text-center py-8">
                  Доклады не добавлены
                </p>
              ) : (
                <div className="space-y-3">
                  {sectionTalks.map((talk) => {
                    const speaker = speakers.find(s => s.id === talk.speaker_id);
                    
                    return (
                      <div key={talk.id} className="border rounded-lg p-4">
                        <div className="flex items-start justify-between mb-2">
                          <h3 className="font-medium">{talk.title}</h3>
                          <Badge variant={talk.status === 'ready' ? 'default' : 'secondary'}>
                            {talk.status === 'ready' ? 'Готов' : 'Черновик'}
                          </Badge>
                        </div>
                        
                        {talk.description && (
                          <p className="text-sm text-muted-foreground mb-3">
                            {talk.description}
                          </p>
                        )}
                        
                        <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
                          {speaker && (
                            <UserDisplay user={speaker} />
                          )}
                          <span className="flex items-center gap-1">
                            <Clock className="size-4" />
                            {formatDate(talk.start_time)}, {formatTime(talk.start_time)} ({talk.duration} мин)
                          </span>
                          {talk.room && (
                            <span className="flex items-center gap-1">
                              <MapPin className="size-4" />
                              {talk.room}
                            </span>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}