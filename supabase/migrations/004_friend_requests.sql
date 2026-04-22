-- Create Friend Requests Table
CREATE TABLE IF NOT EXISTS friend_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  receiver_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(sender_id, receiver_id)
);

-- Create indexes
CREATE INDEX idx_friend_requests_sender_id ON friend_requests(sender_id);
CREATE INDEX idx_friend_requests_receiver_id ON friend_requests(receiver_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);

-- Enable RLS
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view incoming requests" ON friend_requests
  FOR SELECT USING (auth.uid() = receiver_id OR auth.uid() = sender_id);

CREATE POLICY "Authenticated users can send friend requests" ON friend_requests
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update their requests" ON friend_requests
  FOR UPDATE USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can delete their requests" ON friend_requests
  FOR DELETE USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Function to get friends
CREATE OR REPLACE FUNCTION get_friends(user_id UUID)
RETURNS TABLE(id UUID, email TEXT, full_name TEXT, avatar_url TEXT, institution TEXT, department TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT u.id, u.email, u.full_name, u.avatar_url, u.institution, u.department
  FROM users u
  INNER JOIN (
    SELECT CASE 
      WHEN fr.sender_id = get_friends.user_id THEN fr.receiver_id 
      ELSE fr.sender_id 
    END as friend_id
    FROM friend_requests fr
    WHERE (fr.sender_id = get_friends.user_id OR fr.receiver_id = get_friends.user_id)
    AND fr.status = 'accepted'
  ) friends ON u.id = friends.friend_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get blocked users
CREATE OR REPLACE FUNCTION get_blocked_users(user_id UUID)
RETURNS TABLE(id UUID, email TEXT, full_name TEXT, avatar_url TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT u.id, u.email, u.full_name, u.avatar_url
  FROM users u
  INNER JOIN (
    SELECT CASE 
      WHEN fr.sender_id = get_blocked_users.user_id THEN fr.receiver_id 
      ELSE fr.sender_id 
    END as blocked_id
    FROM friend_requests fr
    WHERE (fr.sender_id = get_blocked_users.user_id OR fr.receiver_id = get_blocked_users.user_id)
    AND fr.status = 'blocked'
  ) blocked ON u.id = blocked.blocked_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to remove friend
CREATE OR REPLACE FUNCTION remove_friend(user_id_1 UUID, user_id_2 UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM friend_requests 
  WHERE (sender_id = user_id_1 AND receiver_id = user_id_2)
  OR (sender_id = user_id_2 AND receiver_id = user_id_1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to unblock user
CREATE OR REPLACE FUNCTION unblock_user(blocker_id UUID, blocked_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM friend_requests 
  WHERE sender_id = blocker_id AND receiver_id = blocked_id AND status = 'blocked';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if users are friends
CREATE OR REPLACE FUNCTION are_friends(user_id_1 UUID, user_id_2 UUID)
RETURNS BOOLEAN AS $$
DECLARE
  is_friend BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM friend_requests
    WHERE ((sender_id = user_id_1 AND receiver_id = user_id_2)
    OR (sender_id = user_id_2 AND receiver_id = user_id_1))
    AND status = 'accepted'
  ) INTO is_friend;
  RETURN is_friend;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is blocked
CREATE OR REPLACE FUNCTION is_blocked(blocker_id UUID, blocked_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  blocked BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM friend_requests
    WHERE sender_id = blocker_id AND receiver_id = blocked_id AND status = 'blocked'
  ) INTO blocked;
  RETURN blocked;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for updated_at
CREATE TRIGGER update_friend_requests_updated_at
  BEFORE UPDATE ON friend_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
