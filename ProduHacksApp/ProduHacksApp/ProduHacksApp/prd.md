Problem:
In the modern household, digital entertainment (gaming, social media, and streaming) often competes directly with educational development. Parents frequently find themselves in the role of "enforcer," constantly negotiating screen time limits, while children view reading as a chore that stands in the way of their fun. Current parental control apps focus primarily on restriction (shutting things off) rather than transformation (turning screen time into a reward for growth).

Solution:
LitLink is a mobile-integrated learning platform that bridges the gap between leisure and literacy. Instead of simply blocking apps, it creates a value-based exchange: children "earn" access to their favorite entertainment by completing tailored reading sessions and comprehension checks. By integrating speech-to-text technology and interactive vocabulary tools, the app transforms reading from a static "requirement" into an engaging, interactive "key" to the digital world.

Project objectives:
Increase Literacy Consistency: Ensure children engage with reading material daily through an incentive-based model.
Foster Independence: Provide children with the tools (definitions, visuals, and audio) to navigate difficult texts without constant parental intervention.
Actionable Insights: Empower parents with data-driven reports on their child’s reading level, vocabulary growth, and comprehension speed.
Reduce Friction: Replace "screen time arguments" with a clear, automated system that rewards effort with play.

Scope:
This project focuses on an ios based  experience that manages app accessibility. The system leverages AI-driven content generation to create dynamic quizzes from a library of diverse genres (Science, History, Fiction), ensuring that the content remains fresh and age-appropriate.

Users:
Guilt free Parent or Guardian - They feel overwhelmed by the constant "screen time battle" and are looking for a friction-less, automated way to ensure their child is learning without having to play the role of the "enforcer" themselves.

Screen Hungry Child - They feel a sense of urgency to access their favorite games or apps and are looking for the fastest, most engaging path to unlock their reward while avoiding academic frustration.

Customer Problems & Hypothesis:
Problem 1: I want my child to read consistently, but they are constantly distracted by high-stimulation apps like Roblox, TikTok, or YouTube.

Root Cause 1.1: Entertainment apps are designed for instant dopamine, making the "delayed gratification" of reading feel like a chore by comparison.
Hypothesis 1.1: If we gate entertainment apps behind a reading requirement, then 90% of children will complete their daily reading to access their preferred digital rewards

Root Cause 1.2: Current parental controls are purely restrictive (timers/locks) and don't offer a productive "pathway" to unlock more time.

Hypothesis 1.2: If we turn screentime into an earned currency, then 80% of parents will report a decrease in daily "screentime arguments" with their children.

Problem 2: I want to ensure my child is actually learning, but I don't have the time to sit and supervise every reading session.

Root Cause 2.1: Most reading apps lack a verified "comprehension loop," allowing kids to just flip pages without absorbing the information.

Hypothesis 2.1: If we implement mandatory AI-generated quizzes, then parents will feel more confident that their child is actually comprehending the material.

Root Cause 2.2: Children often get discouraged by difficult vocabulary, leading to "academic frustration" and giving up on the task entirely.

Hypothesis 2.2: If we provide instant visual/audio definitions for hard words, then 70% of children will finish a chapter without asking for parental help.

Functional Requirements:

Core requirements:

The system must allow parents to select specific "High-Dopamine" apps (TikTok, YouTube, Games) to be restricted behind a reading gate.
Upon opening a restricted app, the system must intercept the request and redirect the user to a "Reading Task" screen.
The app must use the microphone to listen to verbal reading to ensure the child is doing their reading.
A quiz consisting of 3–5 dynamically generated questions of mixed multiple choice and free response must be passed with a minimum score (e.g., 80%) before the blocked apps are released. Free response questions will be analyzed by AI agent or verified by parent/guardian to pass.
Once the task is complete, the blocked apps should remain unlocked for a parent-defined duration (e.g., 60 minutes) or until a specific "Curfew" time.

Reader requirements:

A long press on any word must trigger a popup containing a simplified definition along with the option to listen to the proper pronunciation.
For nouns, the popup will include an image generated via nanabanana
The recorder will highlight words pronounced correctly green and words incorrectly pronounced with red
Visual celebrations and vibrations must occur once the child has completed their reading and quiz.
A “library” must exist where the parent can select a collection of books of different genres, categories, and reading levels for the reader to auto select passages from.
Child will be prompted to pick a specific genre to do their reading from (ie. Science, History, Fiction) depending on books chosen in collection.
If the child has above a certain score on their quiz or pronunciation, they gain some amounts of fake currency that can be spent on extra screen time, this incentivizes them to actually study and learn the vocabulary.

Parent control:
Parents must be able to link their account to their children's.
Parents must be able to change settings of their children from the parent dashboard (reading length, books, etc)
Parents can monitor child’s progress: A weekly "Reading Report Card" showing: Average reading speed (Words Per Minute), accuracy in quizzes and tricky words the child frequently clicked on or struggled to pronounce.
An option for parents to manually write specific questions for a book if they want to test specific family-related or religious concepts.
A "Master PIN" that allows a parent to bypass the lock instantly for emergencies or special occasions.

