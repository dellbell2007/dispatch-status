# FiveM & Discord Dispatch Status Plugin

This project creates a real-time link between your Discord server and your FiveM server, allowing authorized members to set an in-game "Dispatch" status using simple slash commands.

## Features

-   **Discord Integration**: Uses `/onduty` and `/offduty` slash commands.
-   **Role-Based Permissions**: Restrict command usage to a specific Discord role (e.g., "COMMS").
-   **Real-Time Updates**: The in-game text updates instantly for all players.
-   **Customizable Display**: Easily change the text color and position in the client-side Lua script.
-   **Secure**: Uses a secret key to ensure requests only come from your bot.

---

## Part 1: FiveM Server Setup

This part involves setting up the Lua scripts on your FiveM game server.

### Prerequisites

-   A running FiveM server.
-   Access to the server's `resources` folder and `server.cfg` file.

### Steps

1.  **Create the Resource Folder**:
    -   In your server's `resources` directory, create a new folder. For example, name it `dispatch-status`.

2.  **Add the Lua Files**:
    -   Place the following three files inside your new `dispatch-status` folder:
        -   `fxmanifest.lua`
        -   `server.lua`
        -   `client.lua`

3.  **Configure the Server Script**:
    -   Open `server.lua` with a text editor.
    -   **Crucially, change the `secretKey`**: Modify the line `local secretKey = "change-this-to-a-very-secret-key"` to a long, random, and private string. **You must use this exact same key in your Discord bot's configuration.**
    -   (Optional) You can change the `listenPort` if the default (`30125`) is already in use.

4.  **Open Firewall Port**:
    -   Ensure the port you specified in `server.lua` (e.g., `30125`) is **open** on your server's firewall and/or router. The Discord bot needs to be able to send HTTP requests to this port.

5.  **Activate the Resource**:
    -   Open your `server.cfg` file.
    -   Add the following line, making sure it matches the folder name you created:
        ```
        ensure dispatch-status
        ```

6.  **Restart Server**:
    -   Restart your FiveM server to load the new resource. Check the server console for a message like `[DispatchStatus] Started listening for dispatch updates...` to confirm it's working.

---

## Part 2: Discord Bot Setup

This part involves setting up the Node.js bot that will listen for commands on Discord.

### Prerequisites

-   [Node.js](https://nodejs.org/) installed on a machine that can run 24/7 (this can be your game server or a separate VPS/computer).
-   A Discord account with permissions to create applications and invite bots to a server.

### Steps

1.  **Create a Discord Bot Application**:
    -   Go to the [Discord Developer Portal](https://discord.com/developers/applications).
    -   Click **New Application**, give it a name, and click **Create**.
    -   Navigate to the **Bot** tab on the left menu.
    -   Click **Add Bot**, then confirm with **Yes, do it!**.
    -   Under the bot's username, click **Reset Token** to view and copy your **Bot Token**. *Treat this like a password and never share it.*
    -   Go to the **OAuth2 -> General** tab and copy your **CLIENT ID**.

2.  **Set Up the Bot Project Folder**:
    -   Create a new folder for your bot on your computer or server (e.g., `dispatch-bot`).
    -   Inside this folder, place the `index.js` and `package.json` files.

3.  **Create the Configuration File**:
    -   In the same folder, create a new file named exactly `.env`.
    -   Open the `.env` file and add the following lines, filling in your specific details:

    ```ini
    # Discord Bot Credentials
    DISCORD_TOKEN=YourBotTokenGoesHere
    CLIENT_ID=YourBotClientIDGoesHere
    GUILD_ID=YourDiscordServerIDGoesHere

    # FiveM Server Connection Details
    FIVEM_SERVER_URL=http://YOUR_SERVER_IP:30125
    FIVEM_SECRET_KEY=TheSameSecretKeyYouPutInServer.lua

    ```
    -   **To get your Guild (Server) ID**: In Discord, enable Developer Mode in `Settings > Advanced`, then right-click your server icon and select **Copy Server ID**.
    -   Replace `YOUR_SERVER_IP` with your FiveM server's public IP address.

4.  **Install Dependencies**:
    -   Open a terminal or command prompt in your bot's project folder.
    -   Run the command:
        ```bash
        npm install
        ```

5.  **Invite the Bot to Your Discord Server**:
    -   Create an invite URL by replacing `YOUR_CLIENT_ID` in the URL below with your bot's Client ID from Step 1.
    -   `https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=8&scope=bot%20applications.commands`
    -   Open the URL in your browser, select your server, and authorize the bot.

6.  **Run the Bot**:
    -   In your terminal, start the bot with the command:
        ```bash
        npm start
        ```
    -   The console should log `Bot is ready!`. The bot will automatically register the `/onduty` and `/offduty` commands in your server.

You are now all set! Users with the "COMMS" role (ID: `923114377245249561`) can use the commands to update the status in-game. For long-term use, consider running the bot with a process manager like [PM2](https://pm2.keymetrics.io/) to keep it online automatically.
