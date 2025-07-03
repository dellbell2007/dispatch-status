// index.js (All-in-One)
// This single file registers commands and runs the bot.

const { Client, GatewayIntentBits, Events, REST, Routes } = require('discord.js');
const axios = require('axios');
require('dotenv').config(); // Loads variables from .env file

// --- CONFIGURATION ---
const requiredRoleId = '923114377245249561'; // COMMS role ID
// ---------------------

// Load configuration from .env file
const token = process.env.DISCORD_TOKEN;
const clientId = process.env.CLIENT_ID;
const guildId = process.env.GUILD_ID;
const fivemUrl = process.env.FIVEM_SERVER_URL;
const secretKey = process.env.FIVEM_SECRET_KEY;

// Basic validation
if (!token || !clientId || !guildId || !fivemUrl || !secretKey) {
    console.error('FATAL: Missing required environment variables in .env file.');
    console.error('Please provide DISCORD_TOKEN, CLIENT_ID, GUILD_ID, FIVEM_SERVER_URL, and FIVEM_SECRET_KEY.');
    process.exit(1);
}

// Define the slash commands that will be registered
const commands = [
    {
        name: 'onduty',
        description: 'Sets the in-game dispatch status to ACTIVE.',
    },
    {
        name: 'offduty',
        description: 'Sets the in-game dispatch status to INACTIVE.',
    },
];

// Create a new Discord REST client to register commands
const rest = new REST({ version: '10' }).setToken(token);

// Create a new Discord bot client
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// --- BOT LOGIC ---

// Function to send the status update to the FiveM server
async function updateFiveMStatus(status) {
    try {
        const response = await axios.post(
            `${fivemUrl}/updateStatus`,
            { status: status },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': secretKey,
                },
            }
        );
        console.log(`Successfully sent status update to FiveM: ${status}`, response.data);
        return { success: true, message: response.data.message };
    } catch (error) {
        console.error('Error sending update to FiveM server:', error.message);
        return { success: false, message: 'Could not connect to the FiveM server.' };
    }
}

// Event listener for when the bot is ready
client.once(Events.ClientReady, () => {
    console.log(`Bot is ready! Logged in as ${client.user.tag}`);
});

// Event listener for slash command interactions
client.on(Events.InteractionCreate, async interaction => {
    if (!interaction.isChatInputCommand()) return;

    // Permission check: Ensure the user has the required role
    if (!interaction.member.roles.cache.has(requiredRoleId)) {
        await interaction.reply({
            content: 'You do not have the required "COMMS" role to use this command.',
            ephemeral: true,
        });
        return;
    }

    const { commandName } = interaction;

    if (commandName === 'onduty') {
        await interaction.deferReply({ ephemeral: true });
        const result = await updateFiveMStatus('active');
        if (result.success) {
            await interaction.editReply('✅ In-game dispatch status has been set to **ACTIVE**.');
        } else {
            await interaction.editReply(`❌ Failed to update status. Reason: ${result.message}`);
        }
    } else if (commandName === 'offduty') {
        await interaction.deferReply({ ephemeral: true });
        const result = await updateFiveMStatus('inactive');
        if (result.success) {
            await interaction.editReply('⛔ In-game dispatch status has been set to **INACTIVE**.');
        } else {
            await interaction.editReply(`❌ Failed to update status. Reason: ${result.message}`);
        }
    }
});


// --- STARTUP FUNCTION ---

// An async function to register commands and then log the bot in.
async function start() {
    try {
        console.log('Started refreshing application (/) commands.');
        // The put method is used to fully refresh all commands in the guild with the current set.
        await rest.put(
            Routes.applicationGuildCommands(clientId, guildId),
            { body: commands },
        );
        console.log('Successfully reloaded application (/) commands.');

        // Log in to Discord with your client's token to start the bot
        client.login(token);

    } catch (error) {
        console.error('Failed to start the bot:', error);
    }
}

// Run the startup function
start();
