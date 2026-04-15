-- Create Storage Buckets for Supabase Storage

-- Create avatars bucket (public)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Create posts bucket (public)
INSERT INTO storage.buckets (id, name, public)
VALUES ('posts', 'posts', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Create resources bucket (public)
INSERT INTO storage.buckets (id, name, public)
VALUES ('resources', 'resources', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Create storage policies for avatars
CREATE POLICY "Anyone can view avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update own avatar" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own avatar" ON storage.objects
  FOR DELETE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Create storage policies for posts
CREATE POLICY "Anyone can view posts" ON storage.objects
  FOR SELECT USING (bucket_id = 'posts');

CREATE POLICY "Authenticated users can upload posts" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'posts' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own posts" ON storage.objects
  FOR UPDATE USING (bucket_id = 'posts' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own posts" ON storage.objects
  FOR DELETE USING (bucket_id = 'posts' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Create storage policies for resources
CREATE POLICY "Anyone can view resources" ON storage.objects
  FOR SELECT USING (bucket_id = 'resources');

CREATE POLICY "Authenticated users can upload resources" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'resources' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own resources" ON storage.objects
  FOR UPDATE USING (bucket_id = 'resources' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own resources" ON storage.objects
  FOR DELETE USING (bucket_id = 'resources' AND auth.uid()::text = (storage.foldername(name))[1]);
