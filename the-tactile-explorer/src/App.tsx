import { useState } from 'react';
import { AppScreen } from './types';
import { LockScreen, ReadingScreen, SummaryScreen } from './components/Screens';
import { ParentDashboard } from './components/ParentDashboard';

export default function App() {
  const [screen, setScreen] = useState<AppScreen>('LOCK');

  const renderScreen = () => {
    switch (screen) {
      case 'LOCK':
        return <LockScreen onStart={() => setScreen('READING')} />;
      case 'READING':
        return <ReadingScreen onFinish={() => setScreen('SUMMARY')} />;
      case 'SUMMARY':
        return <SummaryScreen onBack={() => setScreen('PARENT_DASHBOARD')} />;
      case 'PARENT_DASHBOARD':
        return <ParentDashboard onBack={() => setScreen('LOCK')} />;
      default:
        return <LockScreen onStart={() => setScreen('READING')} />;
    }
  };

  return (
    <div className="min-h-screen bg-surface selection:bg-primary-container selection:text-on-primary-container">
      {renderScreen()}
    </div>
  );
}
