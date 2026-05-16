# Chat System Architecture — Flutter (Riverpod + Firestore)

## نظرة عامة

| الطبقة | المسؤولية |
|--------|-----------|
| **Laravel** | Authentication (Sanctum) · Chat metadata (MySQL) · Avatar URLs |
| **Firebase Firestore** | Realtime messages · Typing state · Online presence |
| **Flutter + Riverpod** | UI · State management · Stream providers |

---

## بنية Firestore

### `chats/{chatId}`

```
participants:    List<String>   ← [clientId, coachId]
clientId:        String
clientName:      String
clientAvatarUrl: String?
coachId:         String
coachName:       String
coachAvatarUrl:  String?
type:            "subscription" | "inquiry"
status:          "active" | "open" | "closed"
lastMessage:     String
lastMessageAt:   Timestamp
createdAt:       Timestamp
typing:          Map<String, bool>   ← { userId: isTyping }
```

### `chats/{chatId}/messages/{messageId}`

```
senderId:  String
text:      String
createdAt: Timestamp
isRead:    Boolean
```

### `users/{userId}` — Online Presence

```
isOnline: Boolean
lastSeen: Timestamp
```

---

## Data Flow

### إنشاء محادثة (من select_coach_screen.dart)

```
SelectCoachScreen
    │
    ├─ GET /api/client/available-experts  (ChatService via ApiService)
    │     ← قائمة المدربين المشترك معهم
    │
    ├─ User يختار مدرباً
    │
    ├─ POST /api/client/chats/start { coach_id }
    │     ← { firebase_chat_id, client_*, coach_*, type, status }
    │
    ├─ FirestoreChatService.ensureChatDoc(...)
    │     setDoc(chats/{id}, payload, merge: true)
    │     - وثيقة جديدة: يضيف createdAt + lastMessage + lastMessageAt
    │     - موجودة: يكمّل الحقول الناقصة فقط
    │
    └─ Navigator.push → ChatDetailsScreen(chatId, title, peerId)
```

### إرسال رسالة

```
ChatInput.onSend(text)
    │
    └─ ChatComposerController.sendMessage(text)
            │
            └─ FirestoreChatService.sendMessage(chatId, senderId, text)
                    │
                    ├─ batch.set(messages/{id}, { senderId, text, createdAt, isRead:false })
                    └─ batch.set(chats/{id}, { lastMessage, lastMessageAt }, merge)
```

### استقبال رسائل (Realtime)

```
messagesStreamProvider(chatId)
    │
    └─ FirestoreChatService.watchMessages(chatId, limit: 50)
            │
            └─ onSnapshot → List<ChatMessageModel> → ListView.builder (reverse: true)
```

### حالة الكتابة (Typing)

```
ChatInput → onChanged
    │
    └─ ChatComposerController.setTyping(isTyping)
            │
            ├─ FirestoreChatService.setTyping(chatId, userId, isTyping)
            │       setDoc({ typing: {userId: isTyping} }, merge)
            │
            └─ _typingTimer: يُلغي true بعد 2 ثانية تلقائياً

typingStreamProvider(chatId)
    └─ FirestoreChatService.watchTyping(chatId)
            └─ onSnapshot → Map<String, bool> → TypingIndicator widget
```

### حالة النشاط (Presence) — الموبايل فقط داخل المحادثة

لا يُعلَم أن المستخدم «متصل» على قائمة المحادثات أو خارج الشات. يُحدَّث `users/{userId}.isOnline` **فقط** أثناء فتح `ChatDetailsScreen`:

```
ChatDetailsScreen
    ├─ initState + microtask → setPresence(currentUserId, isOnline: true)
    ├─ AppLifecycleListener على هذه الشاشة فقط:
    │     onResume → true | onPause / onHide / onDetach → false
    └─ dispose → setPresence(currentUserId, isOnline: false)

presenceStreamProvider(peerId) (AppBar)
    └─ يقرأ ما كتبه الطرف الآخر عندما يكون داخل شاشة المحادثة (أو الويب حسب منطق الويب).
```

`AppEntry` **لا** يكتب presence؛ القائمة الرئيسية لا تُظهر المستخدم كـ online.

---

## الـ Providers

### `chat_providers.dart`

| Provider | النوع | الوصف |
|----------|-------|-------|
| `firestoreProvider` | `Provider<FirebaseFirestore>` | instance واحد لـ Firestore |
| `firestoreChatServiceProvider` | `Provider<FirestoreChatService>` | service الرئيسي |
| `currentUserIdProvider` | `Provider<String?>` | يستخرج user.id من authProvider |
| `currentUserRoleProvider` | `Provider<String?>` | client \| trainer \| nutritionist |
| `chatsStreamProvider` | `StreamProvider<List<ChatModel>>` | قائمة المحادثات realtime |
| `messagesStreamProvider` | `StreamProvider.family<List<ChatMessageModel>, String>` | رسائل محادثة معينة |
| `typingStreamProvider` | `StreamProvider.family<Map<String, bool>, String>` | حالة الكتابة |
| `presenceStreamProvider` | `StreamProvider.family<bool, String>` | isOnline لمستخدم معين |
| `chatComposerProvider` | `StateNotifierProvider.family<ChatComposerController, _, String>` | إرسال + typing |
| `chatPagingProvider` | `StateNotifierProvider.family<ChatPagingController, _, String>` | تحميل رسائل أقدم |

---

## `FirestoreChatService` — الدوال المهمة

| الدالة | الوصف |
|--------|-------|
| `ensureChatDoc({chatId, clientId, ...})` | تزامن Firestore بعد Laravel API. `SetOptions(merge: true)` لا يحذف الرسائل. يضيف الحقول الناقصة فقط. |
| `watchChats(userId)` | Stream على `chats where participants array-contains userId` مرتبة بـ `lastMessageAt desc`. |
| `watchMessages(chatId, limit)` | Stream على `chats/{chatId}/messages orderBy createdAt desc limit`. |
| `sendMessage({chatId, senderId, text})` | WriteBatch: رسالة جديدة + تحديث lastMessage في الوثيقة الرئيسية. |
| `markMessagesAsRead({chatId, userId})` | Batch update لرسائل `isRead=false` من الطرف الآخر (limit 50). |
| `setTyping({chatId, userId, isTyping})` | `setDoc({ typing: {userId: isTyping} }, merge)`. |
| `watchTyping(chatId)` | Stream على وثيقة المحادثة — يستخرج الحقل `typing` فقط. |
| `setPresence(userId, {isOnline})` | يكتب `{ isOnline, lastSeen }` في `users/{userId}` بـ merge. |
| `watchPresence(userId)` | Stream على `users/{userId}` → Map لاستخراج `isOnline`. |
| `fetchOlderMessages({chatId, before, limit})` | Pagination — يجلب رسائل قبل timestamp معين. |

---

## `ChatComposerController` — State Notifier

```dart
state = ChatComposerState {
  isSending:    bool,
  errorMessage: String?,
  isTyping:     bool,
}

Methods:
  sendMessage(text)   → Firestore sendMessage + تحديث lastMessage
  markAsRead()        → markMessagesAsRead في Firestore
  setTyping(isTyping) → setTyping في Firestore + Timer(2s) لإلغاء true تلقائياً
```

---

## شاشات الـ Chat

| الشاشة | الملف | الوصف |
|--------|-------|-------|
| `ChatListScreen` | `screens/chat_list_screen.dart` | قائمة المحادثات من `chatsStreamProvider` |
| `ChatDetailsScreen` | `screens/chat_details_screen.dart` | الرسائل + typing indicator + presence في AppBar |
| `SelectCoachScreen` | `screens/select_coach_screen.dart` | اختيار مدرب وإنشاء محادثة جديدة |

---

## ملاحظات معمارية مهمة

1. **`reverse: true` في ListView** — الرسائل تُعرض من الأحدث للأقدم (أسلوب تطبيقات المراسلة).
2. **`SetOptions(merge: true)`** في كل عمليات الكتابة — لا يُحذف أي بيانات موجودة.
3. **WriteBatch** في `sendMessage` — الرسالة + lastMessage يُكتبان ذرياً (atomic).
4. **`autoDispose`** على كل StreamProviders — يوقف الـ listeners تلقائياً عند مغادرة الشاشة.
5. **Pagination** — `fetchOlderMessages` يستخدم `startAfter([Timestamp])` لجلب الرسائل القديمة.
6. **الـ presence في الموبايل** — يُضبط في `ChatDetailsScreen` فقط (وليس من `AppEntry`).
7. **`peerId`** يُحسب من `chat.otherParticipantId(currentUserId)` عند الانتقال لـ `ChatDetailsScreen`.
