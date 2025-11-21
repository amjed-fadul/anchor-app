import { useState, useEffect } from 'react';
import { supabase } from './lib/supabase';
import Sidebar from './layout/Sidebar';
import MainContent from './layout/MainContent';
import Login from './components/Login';
import { Loader2 } from 'lucide-react';

function App() {
  const [activeTab, setActiveTab] = useState('all');
  const [session, setSession] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center w-[800px] h-[600px] bg-white">
        <Loader2 className="animate-spin text-anchor-teal" size={32} />
      </div>
    );
  }

  if (!session) {
    return (
      <div className="w-[800px] h-[600px] bg-white overflow-hidden font-sans text-anchor-charcoal">
        <Login onLoginSuccess={() => { }} />
      </div>
    );
  }

  return (
    <div className="flex w-[800px] h-[600px] bg-white overflow-hidden font-sans text-anchor-charcoal">
      <Sidebar activeTab={activeTab} onTabChange={setActiveTab} session={session} />
      <MainContent activeTab={activeTab} />
    </div>
  );
}

export default App;
