import { useEffect, useState } from 'react';
import { useTheme } from 'next-themes';
import { Moon, Sun } from 'lucide-react';
import { Button } from './ui/button';

/** Переключение светлой / тёмной темы (для всех ролей на странице профиля и при необходимости в других местах). */
export function ThemeToggle() {
  const { resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return (
      <Button
        variant="outline"
        size="icon"
        className="size-9 shrink-0 border-border bg-card text-foreground shadow-sm"
        disabled
        aria-hidden
      >
        <Sun className="size-[1.15rem]" />
      </Button>
    );
  }

  const isDark = resolvedTheme === 'dark';

  return (
    <Button
      type="button"
      variant="outline"
      size="icon"
      className="size-9 shrink-0 border-border bg-card text-foreground shadow-sm hover:bg-accent"
      onClick={() => setTheme(isDark ? 'light' : 'dark')}
      aria-label={isDark ? 'Включить светлую тему' : 'Включить тёмную тему'}
      title={isDark ? 'Светлая тема' : 'Тёмная тема'}
    >
      {isDark ? <Sun className="size-[1.15rem]" /> : <Moon className="size-[1.15rem]" />}
    </Button>
  );
}
