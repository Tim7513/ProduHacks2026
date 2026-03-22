import React from 'react';
import { motion } from 'motion/react';
import { Settings, Plus, ArrowRight, Award, BookOpen, Heart, Library, BarChart2, Target, User } from 'lucide-react';
import { BOOKS, WEEKLY_PROGRESS, MOCK_STATS } from '../constants';
import { Button, NavPill } from './Screens';

export const ParentDashboard = ({ onBack }: { onBack: () => void }) => (
  <motion.div 
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    className="min-h-screen bg-surface pb-32"
  >
    <header className="sticky top-0 z-50 bg-surface/80 backdrop-blur-md border-b border-surface-container">
      <div className="max-w-screen-xl mx-auto px-6 py-4 flex justify-between items-center">
        <div className="flex items-center gap-3">
          <BookOpen className="text-primary" />
          <h1 className="font-headline font-bold text-lg text-primary tracking-tight">The Tactile Explorer</h1>
        </div>
        <div className="flex items-center gap-4">
          <div className="hidden md:flex items-center gap-6 mr-6">
            <button className="font-label text-sm font-medium text-outline hover:text-primary transition-colors">Resources</button>
            <button className="font-label text-sm font-medium text-outline hover:text-primary transition-colors">Support</button>
          </div>
          <div className="h-10 w-10 rounded-full bg-primary-container flex items-center justify-center overflow-hidden border-2 border-surface-container-highest">
            <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuDKlyC4IixSLic6aef2J76HeI6xPgH_Jf8H_UOCG5yv0EhTDqSsxbMOJV-qJH29ZLXOhrzI4pUNyi9gvWlMtM0i1nG6CJ8qF7vF9xKC43IkhhIsNKqajjMgDNWJq3JJZgoDbWOX5w3KFkRBfVYtX0B70jHIogJnZusjuXJVtOgU-Jxu9FuSP3lE8egJpp1YM4EYwyfg3nYwBmxq9LTPkqvHP4xb2dKs-_18ZsWMbJ41Iauabs7Q-giz0-DBgNfF01F6-gUrDHtjb-o" alt="Sarah" className="w-full h-full object-cover" referrerPolicy="no-referrer" />
          </div>
        </div>
      </div>
    </header>

    <main className="max-w-screen-xl mx-auto px-6 pt-8">
      <div className="flex flex-col md:flex-row md:items-end justify-between mb-10 gap-6">
        <div>
          <span className="font-label text-xs text-outline font-semibold tracking-widest uppercase">Parent Portal</span>
          <h2 className="font-headline text-4xl mt-2 text-on-surface font-extrabold tracking-tight">Hello, Sarah!</h2>
          <p className="text-on-surface-variant mt-1">Leo has read for <span className="text-primary font-bold">{MOCK_STATS.weeklyMinutes} minutes</span> this week.</p>
        </div>
        <div className="flex gap-3">
          <Button variant="outline" className="px-6 py-3">
            <Settings size={20} /> Leo's Settings
          </Button>
          <Button className="px-6 py-3">
            <Plus size={20} /> New Book
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
        {/* Weekly Progress */}
        <div className="md:col-span-8 bg-surface-container-lowest rounded-xl p-8 pop-up-shadow asymmetric-tilt-left">
          <div className="flex justify-between items-center mb-8">
            <h3 className="font-headline text-xl text-on-surface">Weekly Reading Progress</h3>
            <div className="flex gap-2 bg-surface-container-low p-1 rounded-full">
              <button className="px-4 py-1.5 rounded-full text-xs font-bold bg-white text-primary shadow-sm">Minutes</button>
              <button className="px-4 py-1.5 rounded-full text-xs font-bold text-outline">Pages</button>
            </div>
          </div>
          <div className="h-64 flex items-end justify-between gap-4 px-2">
            {WEEKLY_PROGRESS.map((p, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-3">
                <div className="w-full bg-surface-container-low rounded-full h-48 relative flex items-end overflow-hidden">
                  <motion.div 
                    initial={{ height: 0 }}
                    animate={{ height: `${p.minutes}%` }}
                    className={`w-full rounded-full ${p.color === 'tertiary' ? 'bg-tertiary' : p.color === 'primary-container' ? 'bg-primary-container' : p.color === 'surface-variant' ? 'bg-surface-container-highest' : 'bg-primary'}`} 
                  />
                </div>
                <span className="font-label text-[10px] text-outline font-bold">{p.day}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Daily Goal */}
        <div className="md:col-span-4 bg-primary rounded-xl p-8 text-white pop-up-shadow flex flex-col justify-between asymmetric-tilt-right">
          <div>
            <div className="flex justify-between items-start mb-6">
              <Target size={40} />
              <span className="bg-white/20 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Active Goal</span>
            </div>
            <h3 className="font-headline text-2xl font-bold mb-2">Daily Goal</h3>
            <p className="text-white/80 text-sm mb-6 leading-relaxed">Leo is currently aiming for 15 minutes of focused reading every day.</p>
            <div className="flex items-center gap-4 mb-8">
              <button className="w-12 h-12 rounded-full border-2 border-white/30 flex items-center justify-center hover:bg-white/10 transition-colors">
                <Plus size={24} className="rotate-45" />
              </button>
              <div className="flex-1 text-center">
                <span className="text-4xl font-extrabold font-headline tracking-tighter">15</span>
                <span className="block text-[10px] uppercase font-bold text-white/60">MINUTES</span>
              </div>
              <button className="w-12 h-12 rounded-full border-2 border-white/30 flex items-center justify-center hover:bg-white/10 transition-colors">
                <Plus size={24} />
              </button>
            </div>
          </div>
          <button className="w-full bg-white text-primary font-bold py-4 rounded-full shadow-lg active:scale-95 transition-all">
            Update Daily Goal
          </button>
        </div>

        {/* Library */}
        <div className="md:col-span-12 lg:col-span-7 bg-surface-container rounded-xl p-8">
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-headline text-xl text-on-surface">Current Library</h3>
            <button className="text-primary font-bold text-sm flex items-center gap-1">
              View All <ArrowRight size={16} />
            </button>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
            {BOOKS.slice(0, 2).map((book) => (
              <div key={book.id} className="group cursor-pointer">
                <div className="aspect-[3/4] rounded-lg overflow-hidden bg-surface-container-highest mb-3 shadow-md group-hover:-translate-y-2 transition-transform duration-300">
                  <img src={book.coverUrl} alt={book.title} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
                </div>
                <h4 className="font-bold text-sm leading-tight text-on-surface">{book.title}</h4>
                <p className="text-xs text-on-surface-variant">{book.category} • {book.progress}% Done</p>
              </div>
            ))}
            <div className="aspect-[3/4] rounded-lg border-2 border-dashed border-outline-variant flex flex-col items-center justify-center gap-3 hover:border-primary transition-colors group cursor-pointer">
              <div className="w-12 h-12 rounded-full bg-surface-container-low flex items-center justify-center text-outline group-hover:text-primary transition-colors">
                <Plus size={32} />
              </div>
              <span className="text-xs font-bold text-outline">Upload PDF</span>
            </div>
          </div>
        </div>

        {/* Mini Stats */}
        <div className="md:col-span-12 lg:col-span-5 grid grid-cols-2 gap-4">
          <div className="bg-secondary-container rounded-xl p-6 flex flex-col justify-between asymmetric-tilt-left">
            <Award size={32} className="text-secondary" />
            <div>
              <span className="block text-2xl font-extrabold text-on-secondary-container">{MOCK_STATS.badges}</span>
              <span className="text-xs font-bold text-on-secondary-container/70 uppercase">Badges Earned</span>
            </div>
          </div>
          <div className="bg-tertiary-container rounded-xl p-6 flex flex-col justify-between asymmetric-tilt-right">
            <BookOpen size={32} className="text-tertiary" />
            <div>
              <span className="block text-2xl font-extrabold text-on-tertiary-container">{MOCK_STATS.booksCompleted}</span>
              <span className="text-xs font-bold text-on-tertiary-container/70 uppercase">Books Completed</span>
            </div>
          </div>
          <div className="col-span-2 bg-surface-container-lowest rounded-xl p-6 pop-up-shadow">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-full bg-red-100 flex items-center justify-center">
                <Heart size={32} className="text-red-500 fill-red-500" />
              </div>
              <div>
                <h4 className="font-bold text-on-surface">Reading Habit Streak</h4>
                <p className="text-sm text-on-surface-variant">Leo has read {MOCK_STATS.streakDays} days in a row!</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <nav className="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 pb-6 pt-3 bg-white/80 backdrop-blur-xl shadow-[0_-4px_24px_rgba(0,0,0,0.04)] z-50 rounded-t-[3rem]">
      <NavPill icon={Library} label="Library" />
      <NavPill icon={BarChart2} label="Progress" />
      <NavPill icon={Target} label="Goals" />
      <NavPill icon={User} label="Parent" active onClick={onBack} />
    </nav>
  </motion.div>
);
