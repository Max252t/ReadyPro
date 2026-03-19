import { Link } from 'react-router';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Clock, MapPin, User, X } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../../mock-data';
import { UserDisplay } from '../../components/UserDisplay';

export function MySchedulePage() {
  const { user } = useAuth();
  const { talks, sections, schedule, removeFromSchedule } = useData();
  
  const mySchedule = schedule
    .filter(s => s.user_id === user?.id)
    .map(s => talks.find(t => t.id === s.talk_id))
    .filter(Boolean)
    .sort((a, b) => new Date(a!.start_time).getTime() - new Date(b!.start_time).getTime());

  const handleRemove = (talkId: string) => {
    removeFromSchedule(user!.id, talkId);
    toast.success('Удалено из расписания');
  };

  const formatTime = (dateString: string) => {
    return new Date(dateString).toLocaleTimeString('ru-RU', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ru-RU', { 
      weekday: 'long',
      day: 'numeric',
      month: 'long',
    });
  };

  const groupByDate = (talks: typeof mySchedule) => {
    const grouped = new Map<string, typeof mySchedule>();
    
    talks.forEach(talk => {
      if (!talk) return;
      const dateKey = new Date(talk.start_time).toLocaleDateString('ru-RU');
      if (!grouped.has(dateKey)) {
        grouped.set(dateKey, []);
      }
      grouped.get(dateKey)!.push(talk);
    });
    
    return Array.from(grouped.entries());
  };

  const groupedSchedule = groupByDate(mySchedule);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold mb-2">Моё расписание</h1>
        <p className="text-muted-foreground">
          Доклады, которые вы планируете посетить
        </p>
      </div>

      {mySchedule.length === 0 ? (
        <Card>
          <CardContent className="py-16 text-center">
            <p className="text-muted-foreground mb-4">
              Ваше расписание пусто
            </p>
            <Link to="/participant/program">
              <Button>Перейти к программе</Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-6">
          {groupedSchedule.map(([date, talks]) => (
            <Card key={date}>
              <CardHeader>
                <CardTitle>{formatDate(talks[0]!.start_time)}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {talks.map((talk) => {
                    if (!talk) return null;
                    
                    const speaker = mockUsers.find(u => u.id === talk.speaker_id);
                    const section = sections.find(s => s.id === talk.section_id);
                    
                    return (
                      <div key={talk.id} className="border rounded-lg p-4">
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex-1">
                            <Link 
                              to={`/talk/${talk.id}`}
                              className="font-medium text-lg hover:underline"
                            >
                              {talk.title}
                            </Link>
                            {section && (
                              <p className="text-sm text-muted-foreground mt-1">
                                {section.name}
                              </p>
                            )}
                          </div>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleRemove(talk.id)}
                          >
                            <X className="size-4" />
                          </Button>
                        </div>
                        
                        <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
                          {speaker && (
                            <UserDisplay user={speaker} />
                          )}
                          <span className="flex items-center gap-1">
                            <Clock className="size-4" />
                            {formatTime(talk.start_time)} ({talk.duration} мин)
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
              </CardContent>
            </Card>
          ))}

          <Card className="bg-muted">
            <CardContent className="py-6">
              <p className="text-sm text-center text-muted-foreground">
                Всего докладов в расписании: <span className="font-semibold">{mySchedule.length}</span>
              </p>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}