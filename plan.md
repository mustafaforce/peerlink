# PeerLink - Development Plan

## Feature Checklist

### ✅ 1. User Registration (Univ Email OTP)
- **Migration:** `001_users.sql`, `015_users_select_policy.sql`
- **Code:** Auth feature — login, signup, OTP verify, forgot/reset password
- **Status:** Complete — refactored to use `AuthCubit` + Notion design

### ✅ 2. Profile Setup
- **Migration:** `001_users.sql`
- **Code:** Profile feature — view/edit profile, bio, institution, department, year, avatar upload
- **Status:** Complete — avatar upload added, EditProfile uses `ProfileCubit`, Notion design

### ✅ 3. Add Skill (Free/Paid)
- **Migration:** `007_resources.sql`, `012_storage.sql`
- **Code:** Resource feature — upload files with title, desc, institution, department, course, subject
- **Status:** Complete — download now opens file in browser via `url_launcher`, Notion design

### ✅ 4. Search Skill by Category
- **Migration:** `007_resources.sql`
- **Code:** Resource feature — search/filter by institution, department, course, subject
- **Status:** Complete — ResourceList uses `ResourceCubit` with optimistic favorite toggle

### ✅ 5. Send Skill Request
- **Migration:** `004_friend_requests.sql`
- **Code:** Friend feature — send friend request to peer
- **Status:** Complete — Notion design on all friend widgets

### ✅ 6. Accept / Reject Request
- **Migration:** `004_friend_requests.sql`
- **Code:** Friend feature — accept/reject request, block/unblock
- **Status:** Complete — cards with whisper border + warm neutrals

---

### ⬜ 7. In-App Chat

**To Do:**
- [ ] Write SQL migration — chat `conversations` table + `messages` table + RLS policies
- [ ] Write repository — `ChatRepository` (send, getConversations, getMessages, markRead, stream new messages)
- [ ] Write cubit — `ChatCubit` (loadConversations, loadMessages, sendMessage, streamMessages)
- [ ] Write pages — `ConversationsListPage`, `ChatDetailPage`
- [ ] Write widgets — `ConversationTile`, `MessageBubble`, `ChatInput`
- [ ] Register routes in `app_router.dart`
- [ ] Wire into Home navigation
- [ ] Mark complete in `plan.md`

---

### ⬜ 8. Notification System

**To Do:**
- [ ] DB migration already exists — `011_notifications.sql`
- [ ] Write repository — `NotificationRepository` (getNotifications, markRead, markAllRead, streamNotifications)
- [ ] Write cubit — `NotificationCubit` (loadNotifications, markRead, markAllRead, stream)
- [ ] Write pages — `NotificationsPage`
- [ ] Write widgets — `NotificationTile`
- [ ] Add notification badge to Home navigation
- [ ] Register route in `app_router.dart`
- [ ] Wire notification creation into relevant actions (friend request, like, comment, resource upload)
- [ ] Mark complete in `plan.md`

---

## Workflow

1. Write SQL migration for feature
2. Push migration to Supabase
3. Write code — clean architecture (repository → cubit → pages/widgets)
4. Register routes + wire navigation
5. Mark ✅ in this file
6. Wait for command to start next feature
