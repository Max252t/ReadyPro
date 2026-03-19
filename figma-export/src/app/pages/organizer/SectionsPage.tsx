import { useState } from 'react';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Textarea } from '../../components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../../components/ui/dialog';
import { Plus, Pencil, Trash2, Users } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../../mock-data';
import { UserDisplay } from '../../components/UserDisplay';
import type { Section } from '../../types';

export function SectionsPage() {
  const { sections, addSection, updateSection, deleteSection, events } = useData();
  const [open, setOpen] = useState(false);
  const [editingSection, setEditingSection] = useState<Section | null>(null);
  
  const curators = mockUsers.filter(u => u.role === 'curator');
  const currentEvent = events[0];

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    curator_id: '',
    room: '',
  });

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      curator_id: '',
      room: '',
    });
    setEditingSection(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (editingSection) {
      updateSection(editingSection.id, formData);
      toast.success('Секция обновлена');
    } else {
      addSection({
        ...formData,
        event_id: currentEvent.id,
      });
      toast.success('Секция создана');
    }
    
    setOpen(false);
    resetForm();
  };

  const handleEdit = (section: Section) => {
    setEditingSection(section);
    setFormData({
      name: section.name,
      description: section.description,
      curator_id: section.curator_id || '',
      room: section.room || '',
    });
    setOpen(true);
  };

  const handleDelete = (id: string) => {
    if (confirm('Вы уверены, что хотите удалить эту секцию?')) {
      deleteSection(id);
      toast.success('Секция удалена');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold">Управление секциями</h1>
          <p className="text-muted-foreground mt-1">
            Создавайте и редактируйте секции мероприятия
          </p>
        </div>
        
        <Dialog open={open} onOpenChange={(isOpen) => {
          setOpen(isOpen);
          if (!isOpen) resetForm();
        }}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="size-4 mr-2" />
              Добавить секцию
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>
                {editingSection ? 'Редактировать секцию' : 'Новая секция'}
              </DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <Label htmlFor="name">Название</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
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
                <Label htmlFor="curator">Куратор</Label>
                <Select
                  value={formData.curator_id}
                  onValueChange={(value) => setFormData({ ...formData, curator_id: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Выберите куратора" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">Без куратора</SelectItem>
                    {curators.map((curator) => (
                      <SelectItem key={curator.id} value={curator.id}>
                        {curator.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="room">Зал</Label>
                <Input
                  id="room"
                  value={formData.room}
                  onChange={(e) => setFormData({ ...formData, room: e.target.value })}
                  placeholder="Например: Зал А"
                />
              </div>

              <div className="flex gap-2 justify-end">
                <Button type="button" variant="outline" onClick={() => setOpen(false)}>
                  Отмена
                </Button>
                <Button type="submit">
                  {editingSection ? 'Сохранить' : 'Создать'}
                </Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {sections.map((section) => {
          const curator = curators.find(c => c.id === section.curator_id);
          
          return (
            <Card key={section.id}>
              <CardHeader>
                <CardTitle className="flex items-start justify-between">
                  <span>{section.name}</span>
                  <div className="flex gap-1">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleEdit(section)}
                    >
                      <Pencil className="size-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleDelete(section.id)}
                    >
                      <Trash2 className="size-4" />
                    </Button>
                  </div>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  {section.description}
                </p>
                
                {section.room && (
                  <div className="text-sm">
                    <span className="text-muted-foreground">Зал:</span> {section.room}
                  </div>
                )}
                
                {curator ? (
                  <div className="flex items-center gap-2 text-sm">
                    <Users className="size-4 text-muted-foreground" />
                    <UserDisplay user={curator} />
                  </div>
                ) : (
                  <div className="text-sm text-muted-foreground italic">
                    Куратор не назначен
                  </div>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}