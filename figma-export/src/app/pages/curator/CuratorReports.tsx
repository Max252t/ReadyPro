import { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Textarea } from '../../components/ui/textarea';
import { Badge } from '../../components/ui/badge';
import { FileText, MessageSquare } from 'lucide-react';
import { toast } from 'sonner';
import { mockUsers } from '../../mock-data';

export function CuratorReports() {
  const { user } = useAuth();
  const { sections, talks, comments, reports, addReport, updateReport } = useData();
  
  const mySections = sections.filter(s => s.curator_id === user?.id);
  const myTalks = talks.filter(t => 
    mySections.some(s => s.id === t.section_id)
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold mb-2">Отчеты куратора</h1>
        <p className="text-muted-foreground">
          Составьте итоговые отчеты по вашим секциям
        </p>
      </div>

      <div className="space-y-6">
        {mySections.map((section) => {
          const sectionTalks = talks.filter(t => t.section_id === section.id);
          const sectionComments = comments.filter(c => 
            sectionTalks.some(t => t.id === c.talk_id)
          );
          const existingReport = reports.find(r => r.section_id === section.id && r.curator_id === user?.id);
          
          const [reportText, setReportText] = useState(existingReport?.report_text || '');

          const handleSaveReport = () => {
            if (existingReport) {
              updateReport(existingReport.id, { report_text: reportText });
              toast.success('Отчет обновлен');
            } else {
              addReport({
                section_id: section.id,
                curator_id: user!.id,
                report_text: reportText,
              });
              toast.success('Отчет сохранен');
            }
          };

          return (
            <Card key={section.id}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <FileText className="size-5" />
                  {section.name}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="p-4 bg-muted rounded-lg">
                    <p className="text-sm text-muted-foreground">Докладов</p>
                    <p className="text-2xl font-semibold mt-1">{sectionTalks.length}</p>
                  </div>
                  <div className="p-4 bg-muted rounded-lg">
                    <p className="text-sm text-muted-foreground">Вопросов/Комментариев</p>
                    <p className="text-2xl font-semibold mt-1">{sectionComments.length}</p>
                  </div>
                </div>

                <div>
                  <h3 className="font-medium mb-3">Доклады секции</h3>
                  <div className="space-y-2">
                    {sectionTalks.map((talk) => (
                      <div key={talk.id} className="flex items-center justify-between p-3 border rounded">
                        <div>
                          <p className="font-medium text-sm">{talk.title}</p>
                          <p className="text-xs text-muted-foreground mt-1">
                            {new Date(talk.start_time).toLocaleDateString('ru-RU')} • {new Date(talk.start_time).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' })}
                          </p>
                        </div>
                        <Badge variant={talk.status === 'ready' ? 'default' : 'secondary'}>
                          {talk.status === 'ready' ? 'Готов' : 'Черновик'}
                        </Badge>
                      </div>
                    ))}
                  </div>
                </div>

                {sectionComments.length > 0 && (
                  <div>
                    <h3 className="font-medium mb-3 flex items-center gap-2">
                      <MessageSquare className="size-4" />
                      Вопросы и комментарии
                    </h3>
                    <div className="space-y-3 max-h-64 overflow-y-auto">
                      {sectionComments.map((comment) => {
                        const talk = sectionTalks.find(t => t.id === comment.talk_id);
                        const commenter = mockUsers.find(u => u.id === comment.user_id);
                        
                        return (
                          <div key={comment.id} className="p-3 bg-muted rounded-lg">
                            <div className="flex items-center gap-2 mb-2">
                              <span className="text-sm font-medium">
                                {commenter?.avatar} {commenter?.name}
                              </span>
                              <span className="text-xs text-muted-foreground">
                                {new Date(comment.created_at).toLocaleString('ru-RU')}
                              </span>
                            </div>
                            <p className="text-sm mb-1">{comment.message}</p>
                            <p className="text-xs text-muted-foreground">
                              К докладу: {talk?.title}
                            </p>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                <div>
                  <h3 className="font-medium mb-2">Итоговый отчет</h3>
                  <Textarea
                    value={reportText}
                    onChange={(e) => setReportText(e.target.value)}
                    placeholder="Опишите как прошла секция, какие были вопросы, что можно улучшить..."
                    rows={6}
                    className="mb-3"
                  />
                  <Button onClick={handleSaveReport}>
                    {existingReport ? 'Обновить отчет' : 'Сохранить отчет'}
                  </Button>
                </div>
              </CardContent>
            </Card>
          );
        })}

        {mySections.length === 0 && (
          <Card>
            <CardContent className="py-16 text-center">
              <p className="text-muted-foreground">
                У вас нет назначенных секций
              </p>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
