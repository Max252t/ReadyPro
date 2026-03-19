import { useState } from 'react';
import { Link } from 'react-router';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';
import { Clock, MapPin, User, Calendar, CheckCircle } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../../mock-data';
import { UserDisplay } from '../../components/UserDisplay';

export function ProgramPage() {
  const { user } = useAuth();
  const { talks, sections, schedule, addToSchedule, removeFromSchedule } = useData();
  const [selectedDay, setSelectedDay] = useState('all');

  const isInMySchedule = (talkId: string) => {
    return schedule.some(s => s.talk_id === talkId && s.user_id === user?.id);
  };

  const toggleSchedule = (talkId: string) => {
    if (isInMySchedule(talkId)) {
      removeFromSchedule(user!.id, talkId);
      toast.success('Удалено из вашего расписания');
    } else {
      addToSchedule(user!.id, talkId);
      toast.success('Добавлено в ваше расписание');
    }
  };

  const groupedBySection = sections.map(section => ({
    section,
    talks: talks
      .filter(t => t.section_id === section.id && t.status === 'ready')
      .sort((a, b) => new Date(a.start_time).getTime() - new Date(b.start_time).getTime()),
  })).filter(group => group.talks.length > 0);

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

  const getDateKey = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ru-RU');
  };

  const uniqueDates = [...new Set(talks.map(t => getDateKey(t.start_time)))];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold mb-2">Программа мероприятия</h1>
        <p className="text-muted-foreground">
          Выберите доклады для посещения
        </p>
      </div>

      <Tabs defaultValue="all" className="w-full">
        <TabsList>
          <TabsTrigger value="all">Все дни</TabsTrigger>
          {uniqueDates.map((date, idx) => (
            <TabsTrigger key={date} value={date}>
              День {idx + 1}
            </TabsTrigger>
          ))}
        </TabsList>

        <TabsContent value="all" className="space-y-6 mt-6">
          {groupedBySection.map(({ section, talks: sectionTalks }) => (
            <Card key={section.id}>
              <CardHeader>
                <CardTitle className="flex items-center justify-between">
                  <span>{section.name}</span>
                  <Badge variant="outline">{sectionTalks.length} докладов</Badge>
                </CardTitle>
                {section.description && (
                  <p className="text-sm text-muted-foreground mt-2">
                    {section.description}
                  </p>
                )}
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {sectionTalks.map((talk) => {
                    const speaker = mockUsers.find(u => u.id === talk.speaker_id);
                    const inSchedule = isInMySchedule(talk.id);
                    
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
                            {talk.description && (
                              <p className="text-sm text-muted-foreground mt-1">
                                {talk.description}
                              </p>
                            )}
                          </div>
                        </div>
                        
                        <div className="flex flex-wrap gap-4 text-sm text-muted-foreground mb-3">
                          {speaker && (
                            <UserDisplay user={speaker} />
                          )}
                          <span className="flex items-center gap-1">
                            <Calendar className="size-4" />
                            {formatDate(talk.start_time)}
                          </span>
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

                        <Button
                          variant={inSchedule ? 'default' : 'outline'}
                          size="sm"
                          onClick={() => toggleSchedule(talk.id)}
                        >
                          {inSchedule ? (
                            <>
                              <CheckCircle className="size-4 mr-2" />
                              В моём расписании
                            </>
                          ) : (
                            'Буду'
                          )}
                        </Button>
                      </div>
                    );
                  })}
                </div>
              </CardContent>
            </Card>
          ))}
        </TabsContent>

        {uniqueDates.map((date) => (
          <TabsContent key={date} value={date} className="space-y-6 mt-6">
            {groupedBySection.map(({ section, talks: sectionTalks }) => {
              const dayTalks = sectionTalks.filter(t => getDateKey(t.start_time) === date);
              
              if (dayTalks.length === 0) return null;
              
              return (
                <Card key={section.id}>
                  <CardHeader>
                    <CardTitle>{section.name}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      {dayTalks.map((talk) => {
                        const speaker = mockUsers.find(u => u.id === talk.speaker_id);
                        const inSchedule = isInMySchedule(talk.id);
                        
                        return (
                          <div key={talk.id} className="border rounded-lg p-4">
                            <Link 
                              to={`/talk/${talk.id}`}
                              className="font-medium text-lg hover:underline block mb-2"
                            >
                              {talk.title}
                            </Link>
                            
                            <div className="flex flex-wrap gap-4 text-sm text-muted-foreground mb-3">
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

                            <Button
                              variant={inSchedule ? 'default' : 'outline'}
                              size="sm"
                              onClick={() => toggleSchedule(talk.id)}
                            >
                              {inSchedule ? (
                                <>
                                  <CheckCircle className="size-4 mr-2" />
                                  В моём расписании
                                </>
                              ) : (
                                'Буду'
                              )}
                            </Button>
                          </div>
                        );
                      })}
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </TabsContent>
        ))}
      </Tabs>
    </div>
  );
}