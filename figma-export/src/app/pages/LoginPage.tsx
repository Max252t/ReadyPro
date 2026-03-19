import { useState } from 'react';
import { useNavigate } from 'react-router';
import { useAuth } from '../context/AuthContext';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { toast } from 'sonner';
import { mockUsers } from '../mock-data';
import { UserAvatar } from '../components/UserAvatar';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const success = await login(email, password);
    
    if (success) {
      toast.success('Вход выполнен успешно');
      navigate('/dashboard');
    } else {
      toast.error('Неверный email или пароль');
    }
    
    setLoading(false);
  };

  const quickLogin = (userEmail: string) => {
    setEmail(userEmail);
    setPassword('demo');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-3xl">Хакатон 2026</CardTitle>
          <CardDescription>
            Система управления мероприятиями
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ваш@email.com"
                required
              />
            </div>
            
            <div>
              <Label htmlFor="password">Пароль</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
              />
            </div>

            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? 'Вход...' : 'Войти'}
            </Button>
          </form>

          <div className="mt-6">
            <p className="text-sm text-muted-foreground mb-3 text-center">
              Быстрый вход (демо):
            </p>
            <div className="grid grid-cols-2 gap-2">
              {mockUsers.slice(0, 4).map((user) => (
                <Button
                  key={user.id}
                  variant="outline"
                  size="sm"
                  onClick={() => quickLogin(user.email)}
                  className="text-xs flex items-center gap-1.5"
                >
                  <UserAvatar role={user.role} size="sm" />
                  {user.role === 'organizer' ? 'Организатор' : user.role === 'curator' ? 'Куратор' : user.role === 'speaker' ? 'Спикер' : 'Участник'}
                </Button>
              ))}
            </div>
            <div className="mt-2 grid grid-cols-2 gap-2">
              {mockUsers.slice(6, 8).map((user) => (
                <Button
                  key={user.id}
                  variant="outline"
                  size="sm"
                  onClick={() => quickLogin(user.email)}
                  className="text-xs flex items-center gap-1.5"
                >
                  <UserAvatar role={user.role} size="sm" />
                  Участник
                </Button>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}