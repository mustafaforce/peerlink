-- Create Favorite Resources Table
CREATE TABLE IF NOT EXISTS favorite_resources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  resource_id UUID REFERENCES resources(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, resource_id)
);

-- Create indexes
CREATE INDEX idx_favorite_resources_resource_id ON favorite_resources(resource_id);
CREATE INDEX idx_favorite_resources_user_id ON favorite_resources(user_id);

-- Enable RLS
ALTER TABLE favorite_resources ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own favorites" ON favorite_resources
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can add favorites" ON favorite_resources
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove favorites" ON favorite_resources
  FOR DELETE USING (auth.uid() = user_id);
