import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Layout } from './components/Layout';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { UsersPage } from './pages/UsersPage';
import { LawyersPage } from './pages/LawyersPage';
import { TemplatesPage } from './pages/TemplatesPage';
import { ConsultationsPage } from './pages/ConsultationsPage';
import { EscrowPage } from './pages/EscrowPage';
import { DisputesPage } from './pages/DisputesPage';
import { FinancialsPage } from './pages/FinancialsPage';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user, token, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-oqoody-bg flex items-center justify-center">
        <div className="w-8 h-8 border-2 border-oqoody-gold border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!token || !user) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="users" element={<UsersPage />} />
            <Route path="lawyers" element={<LawyersPage />} />
            <Route path="templates" element={<TemplatesPage />} />
            <Route path="consultations" element={<ConsultationsPage />} />
            <Route path="escrow" element={<EscrowPage />} />
            <Route path="disputes" element={<DisputesPage />} />
            <Route path="financials" element={<FinancialsPage />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
};

export default App;

