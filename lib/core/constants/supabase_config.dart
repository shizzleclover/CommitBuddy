class SupabaseConfig {
  static const String supabaseUrl = 'https://oolrrclvxqtspjtxrzlo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vbHJyY2x2eHF0c3BqdHhyemxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxODczNDcsImV4cCI6MjA2NTc2MzM0N30.ZFOIWy25W0ceSqhSkM5Z7xJNlE46u7XQtWdVGa1JxNc';
  
  // Edge Function URLs
  static const String buddyMotivationFunction = '/functions/v1/buddy-motivation';
  static const String subscriptionWebhookFunction = '/functions/v1/subscription-webhook';
  static const String routineAnalyticsFunction = '/functions/v1/routine-analytics';
  
  // Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String buddyAvatarsBucket = 'buddy-avatars';
} 