🎮 Game Summary – Remembrance

At its core, Remembrance uses a modular data system that supports first-time logins, custom character creation, and long-term progression, all stored reliably through Roblox’s DataStore service.

📜 Script Overview
1. playerLaunchDataCollect.lua
Purpose: Determines if the player is logging in for the first time or returning.

Functionality:

Checks for existing saved data in DataStore.

If data exists, the player sees a "Play" button.

If data does not exist, it generates the character creation GUI and disables the "Play" button until creation is complete.

2. createdDataSave.lua
Purpose: Handles saving of new player data during the character creation process.

Functionality:

Captures player input from GUI buttons (e.g., race, gender, appearance).

Packages this data into a structured format.

Sends the data to the server, which stores it in the DataStore.

Enables the "Play" button after successful data save.

3. mainData.lua
Purpose: Manages player data integration into the game world and handles progression.

Functionality:

Loads the player’s saved data upon entering the world.

Spawns the customized character based on saved traits.

Allows future changes to the player's data (e.g., leveling, skill unlocks, gear) to be reflected in the DataStore in real time or at intervals.

🔁 Workflow Summary
First Login: playerLaunchDataCollect.lua → character creation GUI → createdDataSave.lua saves input.

Returning Player: playerLaunchDataCollect.lua detects saved data → enables "Play" immediately.

In-Game Data Use & Progression: mainData.lua loads character and handles ongoing progression updates.
