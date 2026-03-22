import React from 'react';
import { motion } from 'motion/react';
import { BookOpen, Trophy, Target, Settings, ChevronLeft, ChevronRight, Book as BookIcon, Volume2 } from 'lucide-react';

// --- Shared Components ---

export const Button = ({ 
  children, 
  variant = 'primary', 
  className = '', 
  onClick 
}: { 
  children: React.ReactNode; 
  variant?: 'primary' | 'secondary' | 'glass' | 'outline' | 'tertiary';
  className?: string;
  onClick?: () => void;
}) => {
  const variants = {
    primary: 'bg-gradient-to-br from-primary to-primary-container text-white shadow-lg',
    secondary: 'bg-secondary-container text-on-secondary-container',
    tertiary: 'bg-tertiary-container text-on-tertiary-container',
    glass: 'bg-surface-container-lowest/80 backdrop-blur-xl text-primary shadow-2xl',
    outline: 'border-2 border-outline-variant/20 text-on-surface-variant hover:bg-surface-container transition-colors'
  };

  return (
    <motion.button
      whileTap={{ scale: 0.95 }}
      onClick={onClick}
      className={`px-8 py-4 rounded-full font-headline font-bold flex items-center justify-center gap-3 transition-all ${variants[variant]} ${className}`}
    >
      {children}
    </motion.button>
  );
};

export const ProgressBar = ({ progress, label, sublabel }: { progress: number; label: string; sublabel?: string }) => (
  <div className="bg-surface-container-lowest p-6 rounded-xl pop-up-shadow">
    <div className="flex justify-between items-center mb-4">
      <span className="font-label font-bold text-on-surface-variant">{label}</span>
      <span className="font-label font-bold text-primary">{progress}% Done</span>
    </div>
    <div className="w-full h-4 bg-tertiary-container rounded-full relative overflow-hidden">
      <motion.div 
        initial={{ width: 0 }}
        animate={{ width: `${progress}%` }}
        className="absolute left-0 top-0 h-full bg-tertiary rounded-full" 
      />
    </div>
    {sublabel && <p className="mt-4 text-sm text-on-surface-variant leading-relaxed">{sublabel}</p>}
  </div>
);

export const NavPill = ({ icon: Icon, label, active, onClick }: { icon: any; label: string; active?: boolean; onClick?: () => void }) => (
  <button 
    onClick={onClick}
    className={`flex flex-col items-center justify-center px-4 py-2 transition-all ${active ? 'scale-110 -translate-y-2' : 'text-outline'}`}
  >
    <div className={`p-3 rounded-full flex items-center justify-center ${active ? 'bg-gradient-to-br from-primary to-primary-container text-white shadow-lg' : ''}`}>
      <Icon size={24} />
    </div>
    <span className="font-label text-[10px] font-medium tracking-wide mt-1 uppercase">{label}</span>
  </button>
);

// --- Screen Components ---

export const LockScreen = ({ onStart }: { onStart: () => void }) => (
  <motion.div 
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    className="min-h-screen flex items-center justify-center p-6 bg-surface relative overflow-hidden"
  >
    {/* Background Decorations */}
    <div className="absolute inset-0 z-0 opacity-10 flex flex-wrap gap-12 p-12 grayscale pointer-events-none">
       {[...Array(12)].map((_, i) => (
         <div key={i} className="w-24 h-24 bg-surface-container-highest rounded-xl" />
       ))}
    </div>

    <div className="relative z-10 w-full max-w-2xl glass-panel rounded-xl shadow-2xl p-8 md:p-12 border border-white/50 flex flex-col items-center text-center">
      <div className="relative mb-8 asymmetric-tilt-left">
        <div className="absolute inset-0 bg-surface-container-highest rounded-xl translate-x-3 translate-y-3 opacity-30"></div>
        <div className="relative w-48 h-48 md:w-64 md:h-64 rounded-xl overflow-hidden bg-primary-container p-4">
          <img 
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuBMi5V1uh_WoOocXe-nP1BN6BHFRfdBygbxTDsnBtOth2ikG0mevGuTrvZ8xZIXFWI3IBNxycvgkKN8JeevkKybzU48QXl73dKIDWVszfnx19I4rJ1_tJ-LyQo7dVrZvnItkp8OdXRY96muHhkhCPWiIr2A8bJD01OsuwEugT5rmnc5xhG5cWVx3D9uEwyhkFdAPGgp6-Pk4gy-F-h64rwW_ETvjvBre2wEUwLmg7izJIKCgTwWQ_xIImS9eUWlwbbRiwYSz4sPQDA" 
            alt="Mascot" 
            className="w-full h-full object-contain"
            referrerPolicy="no-referrer"
          />
        </div>
      </div>

      <div className="space-y-4 mb-10">
        <h1 className="font-headline font-extrabold text-3xl md:text-5xl text-primary leading-tight tracking-tight">
          Time for your 15-minute reading adventure!
        </h1>
        <p className="text-on-surface-variant text-lg md:text-xl font-medium max-w-md mx-auto">
          The world of stories is waiting. Other apps are taking a nap while we explore!
        </p>
      </div>

      <Button onClick={onStart} className="w-full max-w-sm py-5 text-xl">
        Start Reading <BookOpen size={24} />
      </Button>

      <div className="mt-8 flex items-center gap-4 bg-surface-container-low px-6 py-3 rounded-full">
        <div className="flex gap-1">
          <div className="w-2 h-2 rounded-full bg-secondary"></div>
          <div className="w-2 h-2 rounded-full bg-secondary/40"></div>
          <div className="w-2 h-2 rounded-full bg-secondary/20"></div>
        </div>
        <span className="text-sm font-label font-semibold text-secondary uppercase tracking-widest">Focused Mode Active</span>
      </div>
    </div>

    <div className="fixed top-8 right-8 z-50">
      <div className="flex items-center gap-3 bg-surface-container-lowest/80 backdrop-blur-md px-4 py-2 rounded-full border border-outline-variant/20 shadow-sm">
        <Settings size={16} className="text-outline" />
        <span className="font-label font-bold text-on-surface-variant text-xs uppercase tracking-tight">Parental Lock On</span>
        <div className="w-8 h-8 rounded-full overflow-hidden bg-surface-container">
          <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuA5xnFNXBuu0WWmXguAgh36bC-HM7-4M5Lnh6IsSWJOG6FEc5dNAY8ejY7QJy50cbcH9Dua2TJq2cfYR4sIA8epwxb8HAFjyplMlqeRe8l8NPoasv9FBXVydv7HfG95CFKq0HWl1f_y0a7-awdkBKAG0EV_t_jbyEib7JawBGGa5FG2vMIPXd7d3Sm_liqlkKWdWmsOqFLofqBE-XSAlqH6-rAHqbBvwUDq0hniGFbb3biGUOQ8bePA90oluBJk2SM6siTXAdcYMq8" alt="Parent" className="w-full h-full object-cover" referrerPolicy="no-referrer" />
        </div>
      </div>
    </div>
  </motion.div>
);

export const ReadingScreen = ({ onFinish }: { onFinish: () => void }) => (
  <motion.div 
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    className="min-h-screen bg-surface pb-32"
  >
    <header className="sticky top-0 z-30 bg-surface/80 backdrop-blur-md border-b border-surface-container">
      <div className="max-w-screen-xl mx-auto px-6 py-4 flex justify-between items-center">
        <div className="flex items-center gap-3">
          <button className="p-2 rounded-full hover:bg-surface-container transition-colors">
            <ChevronLeft className="text-primary" />
          </button>
          <span className="font-headline font-bold text-lg text-primary">The Tactile Explorer</span>
        </div>
        <div className="flex items-center gap-2 bg-tertiary-container px-5 py-2 rounded-full shadow-sm">
          <Target size={20} className="text-tertiary" />
          <span className="font-headline font-bold text-tertiary">14:52</span>
        </div>
      </div>
    </header>

    <main className="max-w-screen-xl mx-auto px-6 pt-8 grid grid-cols-1 lg:grid-cols-12 gap-8">
      <div className="lg:col-span-4 flex flex-col gap-6">
        <div className="relative aspect-[4/5] rounded-xl overflow-hidden shadow-2xl asymmetric-tilt-left bg-surface-container-lowest p-4">
          <div className="w-full h-full rounded-lg overflow-hidden relative">
            <img 
              src="https://picsum.photos/seed/forest/800/1000" 
              alt="Cover" 
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent flex flex-col justify-end p-6">
              <h2 className="text-white font-headline font-bold text-2xl leading-tight">The Brave Little Star</h2>
              <p className="text-white/80 font-body text-sm mt-1 italic">Chapter 3: The Moon's Hidden Path</p>
            </div>
          </div>
        </div>
        <ProgressBar 
          progress={75} 
          label="Daily Goal" 
          sublabel="You're doing amazing, Leo! Just 4 more minutes to reach your badge." 
        />
      </div>

      <div className="lg:col-span-8">
        <div className="bg-surface-container-lowest rounded-xl p-8 md:p-12 pop-up-shadow min-h-[600px] flex flex-col">
          <div className="flex-grow overflow-y-auto space-y-8">
            <h1 className="font-headline font-extrabold text-4xl text-on-surface tracking-tight">
              The star shimmered in the dark night sky.
            </h1>
            <div className="flex flex-wrap gap-x-4 gap-y-6">
              {['It', 'felt', 'a', 'little', 'bit'].map((word, i) => (
                <span key={i} className={`font-body text-3xl text-secondary font-semibold bg-secondary-container/30 px-2 rounded-lg ${word === 'bit' ? 'underline decoration-4 decoration-secondary underline-offset-8' : ''}`}>
                  {word}
                </span>
              ))}
              {['lonely', 'among', 'the', 'distant', 'planets.', '"I', 'wish', 'I', 'could', 'find', 'a', 'friend,"', 'the', 'star', 'whispered', 'to', 'the', 'comet.'].map((word, i) => (
                <span key={i} className="font-body text-3xl text-on-surface/90 hover:text-primary transition-colors cursor-pointer">
                  {word}
                </span>
              ))}
            </div>
          </div>

          <div className="mt-12 flex flex-col items-center justify-center border-t border-surface-container pt-8 gap-6">
            <div className="relative">
              <motion.div 
                animate={{ scale: [1, 1.2, 1] }}
                transition={{ repeat: Infinity, duration: 2 }}
                className="absolute inset-0 bg-primary/20 rounded-full" 
              />
              <button 
                onClick={onFinish}
                className="relative bg-gradient-to-br from-primary to-primary-container w-24 h-24 rounded-full flex items-center justify-center text-white shadow-xl active:scale-95 transition-all reading-glow"
              >
                <div className="bg-white/20 p-4 rounded-full">
                  <div className="w-8 h-8 bg-white rounded-full flex items-center justify-center">
                    <div className="w-4 h-4 bg-primary rounded-full" />
                  </div>
                </div>
              </button>
            </div>
            <div className="text-center">
              <p className="font-headline font-bold text-primary text-xl">I'm listening...</p>
              <p className="font-body text-on-surface-variant mt-1">Read the word <span className="font-bold text-on-surface">"lonely"</span> next!</p>
            </div>
          </div>
        </div>
      </div>
    </main>

    <nav className="fixed bottom-0 left-0 w-full z-50 px-6 pb-8 pointer-events-none">
      <div className="max-w-screen-xl mx-auto flex justify-between items-center pointer-events-auto">
        <Button variant="glass" className="w-16 h-16 p-0"><ChevronLeft size={32} /></Button>
        <div className="flex gap-4">
          <Button variant="glass" className="px-8 py-4"><BookIcon size={20} /> Dictionary</Button>
          <Button variant="glass" className="px-8 py-4"><Volume2 size={20} /> Hear Sentence</Button>
        </div>
        <Button className="w-16 h-16 p-0"><ChevronRight size={32} /></Button>
      </div>
    </nav>
  </motion.div>
);

export const SummaryScreen = ({ onBack }: { onBack: () => void }) => (
  <motion.div 
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    className="min-h-screen bg-surface flex flex-col items-center p-6 bg-[radial-gradient(circle_at_20%_30%,#68abff_2px,transparent_2px),radial-gradient(circle_at_80%_10%,#fdd355_3px,transparent_3px)] bg-[length:100px_100px]"
  >
    <section className="flex flex-col items-center text-center mt-12 mb-12">
      <div className="relative mb-6">
        <div className="w-48 h-48 md:w-64 md:h-64 bg-secondary-container rounded-full flex items-center justify-center shadow-lg relative z-10">
          <img 
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuBJuhCr5Pn6EF1M5DNX1vBqAZ26-QNRX3Q1GUf00FlszJDygSHORuhmOi_kjkrTvPdpbfBLczY85-tZEKDf1Vp3Wr5UkdKULI8QBSaZK85xJv6t3d9IyR3DVNEZFpkwTVRjEB8VdkE2E4GGh-rCKE76l3jQfux9xL16yt1IP6RzTHt8pLAQy7cRuc7kcptRuHk0BVuSWJQRyT3_i7z_Kn3kzcotx70mWA5O5S89BfhTbelXqFpIhaxMb2HHkcw-_wipuVdC_Q1jZ5o" 
            alt="Mascot" 
            className="w-40 h-40 md:w-52 md:h-52 object-contain"
            referrerPolicy="no-referrer"
          />
        </div>
        <div className="absolute -top-4 -right-4 w-16 h-16 bg-tertiary-container rounded-full flex items-center justify-center asymmetric-tilt-right shadow-md">
          <Trophy size={32} className="text-tertiary" />
        </div>
      </div>
      <h2 className="font-headline text-4xl md:text-5xl font-extrabold text-primary mb-2 tracking-tight">Great job!</h2>
      <p className="font-body text-xl md:text-2xl text-on-surface-variant font-medium">You finished your reading!</p>
    </section>

    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-4xl mb-12">
      <div className="bg-surface-container-lowest p-8 rounded-xl flex flex-col items-center justify-center asymmetric-tilt-left pop-up-shadow border border-outline-variant/10">
        <span className="text-on-surface-variant font-label font-semibold mb-2 uppercase">Words Read</span>
        <span className="font-headline text-5xl text-primary font-extrabold">412</span>
        <div className="mt-4 px-4 py-1 bg-primary-container/20 rounded-full">
          <span className="text-primary font-label font-bold">+12% vs last week</span>
        </div>
      </div>
      <div className="bg-surface-container-lowest p-8 rounded-xl flex flex-col items-center justify-center pop-up-shadow border border-outline-variant/10">
        <span className="text-on-surface-variant font-label font-semibold mb-2 uppercase">Reading Time</span>
        <span className="font-headline text-5xl text-on-surface font-extrabold">15<span className="text-2xl ml-1 text-on-surface-variant">min</span></span>
      </div>
      <div className="bg-surface-container-lowest p-8 rounded-xl flex flex-col items-center justify-center asymmetric-tilt-right pop-up-shadow border border-outline-variant/10">
        <span className="text-on-surface-variant font-label font-semibold mb-2 uppercase">Badge Earned</span>
        <div className="w-24 h-24 bg-gradient-to-br from-tertiary-container to-tertiary rounded-full flex items-center justify-center shadow-lg">
          <Trophy size={48} className="text-on-tertiary-container" />
        </div>
        <span className="mt-4 font-headline text-lg text-tertiary font-bold">Deep Sea Diver</span>
      </div>
    </div>

    <div className="flex flex-col items-center gap-6 w-full max-w-sm">
      <Button className="w-full py-5 text-xl">Unlock Device</Button>
      <button onClick={onBack} className="font-label font-semibold text-outline hover:text-primary transition-colors">
        Back to Library
      </button>
    </div>
  </motion.div>
);
