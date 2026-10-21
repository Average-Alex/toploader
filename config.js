// config.js: tells the website WHICH Supabase project to use.
//
// Supabase is the online database that stores accounts, listings, and photos.
// index.html loads this file first, then reads these two settings to connect.
//
// Both values come from the Supabase dashboard: Project Settings > API.
//
// Is it safe for these to be public? Yes. The "anon" key only lets people do
// what the database's security rules allow (see setup.sql): anyone can read
// listings, and people can only add, change, or delete their own. NEVER put
// the "service_role" or "secret" key here: that one ignores all the rules.

// window.TOPLOADER_CONFIG makes these settings visible to the code in index.html.
window.TOPLOADER_CONFIG = {
  // The address of your Supabase project.
  supabaseUrl: "https://hzepctoivtgzwlfvveur.supabase.co",
  // The public "anon" key, which identifies this website to Supabase.
  supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6ZXBjdG9pdnRnendsZnZ2ZXVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1MTIxODIsImV4cCI6MjEwODA4ODE4Mn0.Z6ibgWfAbOkSrCv3drMVLyKpfuxqU1eJCtS73RTEuCo",
};
