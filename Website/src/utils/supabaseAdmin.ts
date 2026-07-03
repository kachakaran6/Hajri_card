import { createClient } from '@supabase/supabase-js';

// Service-role client — bypasses RLS. Admin use only.
const supabaseUrl = 'https://fiktavtugdnzwueyajuy.supabase.co';
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpa3RhdnR1Z2Ruend1ZXlhanV5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjkxMjk5OCwiZXhwIjoyMDk4NDg4OTk4fQ.iCvMZ3pMH0l7qK_VdcKNbvIKuXKr7GLMzQb0tN9iubs';

export const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});
