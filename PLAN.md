VisuaLit - Project Development Plan & Architecture
Version: 1.0
Date: June 29, 2025

1. Project Vision & Goals
   VisuaLit is an AI-powered, multi-sensory reading platform designed to enhance comprehension, engagement, and accessibility. This project is a rebuild and evolution of the existing VisuaLit application, focusing on a more robust, scalable, and maintainable architecture.

Core Goals:

Rebuild Core Functionality: Re-implement the existing reader, audiobook player, and AI-generation workflows on a modern, stable foundation.

Enhance User Experience: Evolve the UI with a premium feel, improving performance and usability.

Scale for the Future: Build a foundation that can easily accommodate the ambitious future roadmap, including community features and advanced cognitive tools.

2. Core Architecture
   The application will be built on three core pillars, chosen for scalability and alignment with modern Flutter development practices.

Backend: Appwrite

Reasoning: A powerful, open-source backend that provides a structured database, authentication, file storage (for books/audio), and serverless functions. It's a perfect fit for the existing project's needs.

State Management: Riverpod

Reasoning: A strategic upgrade from Provider. Riverpod offers compile-time safety, decouples state from the widget tree, and simplifies managing complex app states (e.g., auth status, async operations), making it ideal for this project's scale.

Routing: GoRouter

Reasoning: The official routing package from the Flutter team. Its URL-based approach is perfect for handling deep links, nested navigation (for the main bottom nav bar), and creating a logical, maintainable navigation structure.

3. Design System & Philosophy
   The goal is to evolve the established VisuaLit design into a more modern and premium experience.

Core Theme: Black, White, & Green (#2ECC71 as a primary accent).

Design Philosophy: "Flair with Focus." We will use gradients strategically to add depth and visual interest to key screens (like onboarding, auth, and home page headers) while ensuring that core content areas (like the reader and settings) prioritize clean, readable white space.

Typography: A clean, highly legible font will be chosen and used consistently.

Reusable Components: We will create a dedicated design system in lib/core/theme/widgets/. This will house custom, reusable components like PrimaryButton, GradientAppBar, and BookCard to ensure consistency and speed up development.

4. Key Libraries & Packages
   EPUB Parsing: epub_view

Reasoning: Provides an all-in-one widget for both parsing and displaying EPUB files, with a rich controller for interactivity (selection, navigation). This accelerates the development of the core reader.

Audiobook Playback: just_audio + audio_service

Reasoning: The industry-standard combination for professional-grade audio apps. It provides robust background playback, lock screen controls, and playlist management.

Fallback TTS: flutter_tts

Reasoning: The simplest and most reliable way to access the device's native Text-to-Speech engine for instant narration.

Local File Access: file_picker

Reasoning: The secure, modern way to let users select their own book files without requiring broad storage permissions.

Image Caching: cached_network_image

Reasoning: Essential for performance. It will automatically cache book covers and other remote images to ensure smooth scrolling and fast load times.

5. Robustness & Security Plan
   Error Handling (User-Centric):

App Errors: Display user-friendly error dialogs instead of crashing.

AI Feedback Loop: For failed AI generations, provide a "Give Feedback" button. This will send the context of the error to our backend, creating a valuable dataset for model improvement.

Caching Strategy:

Images: Use cached_network_image.

Data: Cache API responses from Appwrite (e.g., marketplace list) to reduce network calls.

User State: Locally persist the user's last reading position and theme/font preferences for an instant-on experience.

Client-Side Security:

Runtime Secrets: Use flutter_secure_storage to securely store the user's Appwrite session token.

Build-time Secrets: Use .env files (via flutter_dotenv) to manage API keys and the Appwrite Project ID, ensuring they are not committed to source control.

6. Phased Development Roadmap
   Phase 1: Rebuild the Core Reader & Listener Experience
   The goal of this phase is to have a stable, modern, and usable version of the core app.

Setup & Auth: Initialize the project, folder structure, and design system. Build the complete authentication flow (Splash, Onboarding, Login, Signup) connecting to Appwrite.

Library & Book Handling:

Implement the UI for the main book/audiobook library screens.

Fetch user's purchased content from Appwrite.

Implement local file importing using file_picker.

Core Reader UI:

Develop the main reading screen using epub_view.

Implement interactive features: on-tap dictionary, highlighting, and read-aloud (TTS).

Audiobook Player:

Develop the full-featured audiobook player using just_audio and audio_service.

Implement the mini-player, full-screen player, background controls, and lock screen notifications.

Basic AI Workflow:

Implement the client-side logic for the asynchronous generation flow.

Build the API service to call the FastAPI backend to request generation.

Create the polling mechanism to check for results and update the UI (e.g., shimmer FAB).

Phase 2: Platform & Commercial Module Integration
Marketplace: Build the UI for browsing and acquiring new content.

Author & Admin Portals: Begin work on the web-based interfaces.

Phase 3: Future Vision & Community Expansion
Community Foundation: Build user profiles, friends, and leaderboards.

Advanced Reader Tools: Begin implementing features from the future roadmap (e.g., speed reading, cognitive skill builders).

Creative Tools: Prototype a content generation feature (e.g., automatic graphic novel generation).

7. Project Folder Structure (lib/)
   lib/
   |
   |-- main.dart               # App entry point & service initialization
   |
   |-- core/                   # Shared logic, services, and utilities
   |   |-- api/                # API services (Appwrite, AI Backend)
   |   |-- router/             # GoRouter configuration
   |   |-- theme/              # Design System (colors, fonts, widgets)
   |   |   |-- app_colors.dart
   |   |   |-- app_typography.dart
   |   |   |-- widgets/
   |   |-- models/             # Core data models (User, Book, etc.)
   |   |-- utils/              # Constants, formatters, etc.
   |
   |-- features/               # Individual feature modules
   |   |
   |   |-- auth/               # Authentication (Login, Signup)
   |   |   |-- data/             # Auth repository
   |   |   |-- presentation/     # Screens & Riverpod Notifiers
   |   |
   |   |-- library/            # User's book library
   |   |   |-- ...
   |   |
   |   |-- reader/             # Ebook reading screen
   |   |   |-- ...
   |   |
   |   |-- audiobook_player/   # Audiobook player screen
   |   |   |-- ...
   |
   |-- shared_widgets/         # Common widgets used across multiple features
