import { UserAvatar } from './UserAvatar';
import type { User } from '../types';

interface UserDisplayProps {
  user: User;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function UserDisplay({ user, size = 'sm', className = '' }: UserDisplayProps) {
  return (
    <span className={`inline-flex items-center gap-1.5 ${className}`}>
      <UserAvatar role={user.role} size={size} />
      <span>{user.name}</span>
    </span>
  );
}
