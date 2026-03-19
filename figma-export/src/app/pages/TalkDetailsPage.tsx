import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router';
import { useAuth } from '../context/AuthContext';
import { useData } from '../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Textarea } from '../components/ui/textarea';
import { Label } from '../components/ui/label';
import { Badge } from '../components/ui/badge';
import { Separator } from '../components/ui/separator';
import { ArrowLeft, Clock, MapPin, User, MessageSquare, Star, Send } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../mock-data';
import { UserDisplay } from '../components/UserDisplay';

export function TalkDetailsPage() {
  const { id } = useParams();
  const { user } = useAuth();
  const { talks, sections, comments, addComment, feedback, addFeedback } = useData();
  
  const talk = talks.find(t => t.id === id);
  const section = talk ? sections.find(s => s.id === talk.section_id) : null;
  const speaker = talk ? mockUsers.find(u => u.id === talk.speaker_id) : null;
  const talkComments = comments.filter(c => c.talk_id === id);
  const talkFeedback = feedback.filter(f => f.talk_id === id);
  const myFeedback = talkFeedback.find(f => f.user_id === user?.id);
  
  const [newComment, setNewComment] = useState('');
  const [rating, setRating] = useState(5);
  const [feedbackComment, setFeedbackComment] = useState('');
  const [showFeedbackForm, setShowFeedbackForm] = useState(false);

  // Имитация realtime - обновление каждые 5 секунд
  const [, setTick] = useState(0);
  useEffect(() => {
    const interval = setInterval(() => {
      setTick(t => t + 1);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  if (!talk) {
    return (
      <div className="text-center py-16">
        <p className="text-muted-foreground mb-4">Доклад не найден</p>
        <Link to="/participant/program">
          <Button>Вернуться к программе</Button>
        </Link>
      </div>
    );
  }

  const handleSendComment = () => {
    if (!newComment.trim()) return;
    
    addComment({
      talk_id: talk.id,
      user_id: user!.id,
      message: newComment,
    });
    
    setNewComment('');
    toast.success('Вопрос отправлен');
  };

  const handleSubmitFeedback = () => {
    if (myFeedback) {
      toast.error('Вы уже оставили отзыв на этот доклад');
      return;
    }

    addFeedback({
      talk_id: talk.id,
      user_id: user!.id,
      rating,
      comment: feedbackComment,
    });
    
    setShowFeedbackForm(false);
    setFeedbackComment('');
    toast.success('Спасибо за отзыв!');
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

  const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString('ru-RU', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const averageRating = talkFeedback.length > 0
    ? (talkFeedback.reduce((sum, f) => sum + f.rating, 0) / talkFeedback.length).toFixed(1)
    : null;

  const isCurator = section && section.curator_id === user?.id;

  return (
    <div className="space-y-6 max-w-4xl">
      <Link to="/participant/program">
        <Button variant="ghost" size="sm">
          <ArrowLeft className="size-4 mr-2" />
          Назад к программе
        </Button>
      </Link>

      <Card>
        <CardHeader>
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <CardTitle className="text-2xl mb-2">{talk.title}</CardTitle>
              {section && (
                <Badge variant="outline" className="mb-2">{section.name}</Badge>
              )}
            </div>
            <Badge variant={talk.status === 'ready' ? 'default' : 'secondary'}>
              {talk.status === 'ready' ? 'Готов' : 'Черновик'}
            </Badge>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {talk.description && (
            <p className="text-muted-foreground">{talk.description}</p>
          )}
          
          <div className="flex flex-wrap gap-4 text-sm">
            {speaker && (
              <div className="flex items-center gap-2">
                <User className="size-4 text-muted-foreground" />
                <span>{speaker.avatar} {speaker.name}</span>
              </div>
            )}
            <div className="flex items-center gap-2">
              <Clock className="size-4 text-muted-foreground" />
              <span>{formatDate(talk.start_time)}, {formatTime(talk.start_time)} ({talk.duration} мин)</span>
            </div>
            {talk.room && (
              <div className="flex items-center gap-2">
                <MapPin className="size-4 text-muted-foreground" />
                <span>{talk.room}</span>
              </div>
            )}
          </div>

          {averageRating && (
            <div className="flex items-center gap-2 pt-2">
              <Star className="size-5 fill-yellow-400 text-yellow-400" />
              <span className="font-semibold">{averageRating}</span>
              <span className="text-sm text-muted-foreground">
                ({talkFeedback.length} {talkFeedback.length === 1 ? 'отзыв' : 'отзывов'})
              </span>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="size-5" />
            Вопросы и обсуждение
            <Badge variant="outline" className="ml-auto">{talkComments.length}</Badge>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-3 max-h-96 overflow-y-auto">
            {talkComments.length === 0 ? (
              <p className="text-center text-muted-foreground py-8">
                Пока нет вопросов. Будьте первым!
              </p>
            ) : (
              talkComments.map((comment) => {
                const author = mockUsers.find(u => u.id === comment.user_id);
                
                return (
                  <div key={comment.id} className="p-4 border rounded-lg">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="font-medium">
                        {author?.avatar} {author?.name}
                      </span>
                      <span className="text-xs text-muted-foreground">
                        {formatDateTime(comment.created_at)}
                      </span>
                      {comment.user_id === speaker?.id && (
                        <Badge variant="secondary" className="text-xs">Спикер</Badge>
                      )}
                      {comment.user_id === section?.curator_id && (
                        <Badge variant="secondary" className="text-xs">Куратор</Badge>
                      )}
                    </div>
                    <p className="text-sm">{comment.message}</p>
                  </div>
                );
              })
            )}
          </div>

          <Separator />

          <div className="space-y-3">
            <Label>Ваш вопрос</Label>
            <div className="flex gap-2">
              <Input
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                placeholder="Задайте вопрос спикеру..."
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleSendComment();
                  }
                }}
              />
              <Button onClick={handleSendComment}>
                <Send className="size-4" />
              </Button>
            </div>
            {isCurator && (
              <p className="text-xs text-muted-foreground">
                💡 Вы куратор этой секции и можете отвечать на вопросы
              </p>
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Star className="size-5" />
            Обратная связь
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {myFeedback ? (
            <div className="p-4 bg-muted rounded-lg">
              <p className="font-medium mb-2">Ваша оценка</p>
              <div className="flex gap-1 mb-2">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star
                    key={star}
                    className={`size-5 ${
                      star <= myFeedback.rating
                        ? 'fill-yellow-400 text-yellow-400'
                        : 'text-muted-foreground'
                    }`}
                  />
                ))}
              </div>
              {myFeedback.comment && (
                <p className="text-sm text-muted-foreground">{myFeedback.comment}</p>
              )}
            </div>
          ) : showFeedbackForm ? (
            <div className="space-y-4">
              <div>
                <Label>Оценка</Label>
                <div className="flex gap-2 mt-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <button
                      key={star}
                      type="button"
                      onClick={() => setRating(star)}
                      className="transition-transform hover:scale-110"
                    >
                      <Star
                        className={`size-8 ${
                          star <= rating
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-muted-foreground'
                        }`}
                      />
                    </button>
                  ))}
                </div>
              </div>
              
              <div>
                <Label>Комментарий (необязательно)</Label>
                <Textarea
                  value={feedbackComment}
                  onChange={(e) => setFeedbackComment(e.target.value)}
                  placeholder="Поделитесь своим мнением о докладе..."
                  rows={4}
                  className="mt-2"
                />
              </div>

              <div className="flex gap-2">
                <Button onClick={handleSubmitFeedback}>
                  Отправить отзыв
                </Button>
                <Button variant="outline" onClick={() => setShowFeedbackForm(false)}>
                  Отмена
                </Button>
              </div>
            </div>
          ) : (
            <Button onClick={() => setShowFeedbackForm(true)}>
              Оставить отзыв
            </Button>
          )}

          {talkFeedback.length > 0 && (
            <>
              <Separator />
              <div>
                <h3 className="font-medium mb-3">Отзывы участников</h3>
                <div className="space-y-3">
                  {talkFeedback.filter(f => f.comment).map((fb) => {
                    const author = mockUsers.find(u => u.id === fb.user_id);
                    
                    return (
                      <div key={fb.id} className="p-3 border rounded-lg">
                        <div className="flex items-center gap-2 mb-2">
                          <span className="text-sm font-medium">
                            {author?.avatar} {author?.name}
                          </span>
                          <div className="flex gap-0.5">
                            {[1, 2, 3, 4, 5].map((star) => (
                              <Star
                                key={star}
                                className={`size-3 ${
                                  star <= fb.rating
                                    ? 'fill-yellow-400 text-yellow-400'
                                    : 'text-muted-foreground'
                                }`}
                              />
                            ))}
                          </div>
                        </div>
                        <p className="text-sm text-muted-foreground">{fb.comment}</p>
                      </div>
                    );
                  })}
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}