# TASKS.md

## Feature: User Preferences & Last Read Book Persistence

### Description
Persist user preferences (e.g., theme, font size, reading mode) and last read book (with position) for both guest and logged-in users. Use `shared_preferences` for guests and sync with Appwrite for authenticated users.

---

### Tasks

- [ ] **Design Data Model**
    - Define what preferences and reading state need to be saved (e.g., font, theme, last book, last position).

- [ ] **Provider Setup**
    - Create a Riverpod provider for user preferences and reading state.
    - Ensure it can switch between local and remote sources based on auth state.

- [ ] **Local Persistence (Guest)**
    - Integrate `shared_preferences` for storing preferences and last read book locally.

- [ ] **Remote Sync (Authenticated)**
    - Implement Appwrite database sync for logged-in users.
    - Add local caching for fast access.

- [ ] **Initialization**
    - Initialize/hydrate the provider after auth state is determined (in app router logic).

- [ ] **Integration**
    - Update reading screen and book details sheet to read/write from the provider.

- [ ] **Testing**
    - Test persistence for both guest and logged-in flows.
    - Ensure seamless migration when a guest logs in.

---

### Dependencies

- Reading screen and book details sheet must be implemented first.
- Appwrite database schema for user preferences and reading state.

---

### References

- See `PLAN.md` section 5 and 6 for robustness and roadmap.