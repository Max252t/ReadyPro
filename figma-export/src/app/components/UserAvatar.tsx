import { User, UserCog, Presentation, Users } from 'lucide-react';
import type { UserRole } from '../types';

interface UserAvatarProps {
  role: UserRole;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function UserAvatar({ role, size = 'md', className = '' }: UserAvatarProps) {
  const sizeClasses = {
    sm: 'size-4',
    md: 'size-5',
    lg: 'size-8',
  };

  const iconProps = {
    className: `${sizeClasses[size]} ${className}`,
    strokeWidth: 2,
  };

  switch (role) {
    case 'organizer':
      return <UserCog {...iconProps} />;
    case 'curator':
      return <Users {...iconProps} />;
    case 'speaker':
      return <Presentation {...iconProps} />;
    case 'participant':
      return <User {...iconProps} />;
    default:
      return <User {...iconProps} />;
  }
}
