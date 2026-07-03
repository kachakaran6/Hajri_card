import { createClient } from '@supabase/supabase-js';

// Get credentials from environment or default to project credentials from .env
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://fiktavtugdnzwueyajuy.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpa3RhdnR1Z2Ruend1ZXlhanV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5MTI5OTgsImV4cCI6MjA5ODQ4ODk5OH0.Vy9zttfsm-nQgsfzAWAGp3FMTKQb-IABFFlzn4eXjwI';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
