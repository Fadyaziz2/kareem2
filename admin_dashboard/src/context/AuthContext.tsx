import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '../types';
import { adminApi } from '../services/api';
import { mockCurrentUser } from '../data/mockData';

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (emailOrPhone: string, pass: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
  hasRole: (roles: string[]) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check localStorage
    const savedToken = localStorage.getItem('oqoody_admin_token');
    const savedUser = localStorage.getItem('oqoody_admin_user');

    if (savedToken && savedUser) {
      try {
        setToken(savedToken);
        setUser(JSON.parse(savedUser));
      } catch (e) {
        console.error('Failed to parse saved user', e);
        localStorage.removeItem('oqoody_admin_token');
        localStorage.removeItem('oqoody_admin_user');
      }
    } else {
      // Set default demo super admin for fast previewing if not set
      setToken('demo-token');
      setUser(mockCurrentUser);
      localStorage.setItem('oqoody_admin_token', 'demo-token');
      localStorage.setItem('oqoody_admin_user', JSON.stringify(mockCurrentUser));
    }
    setIsLoading(false);
  }, []);

  const login = async (emailOrPhone: string, pass: string) => {
    setIsLoading(true);
    try {
      const data = await adminApi.login(emailOrPhone, pass);
      setToken(data.token);
      setUser(data.user);
      localStorage.setItem('oqoody_admin_token', data.token);
      localStorage.setItem('oqoody_admin_user', JSON.stringify(data.user));
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem('oqoody_admin_token');
    localStorage.removeItem('oqoody_admin_user');
  };

  const hasRole = (roles: string[]) => {
    if (!user) return false;
    if (user.role === 'super_admin') return true;
    return roles.includes(user.role);
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout, isLoading, hasRole }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

