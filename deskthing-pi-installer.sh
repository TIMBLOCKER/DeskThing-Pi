#!/bin/bash
. $HOME

#Execute on ~/
#This installer will download and create all neccessary components to run DeskThing on Raspberry Pi 4

echo "..........   -+*:   ............................................................................................................."
echo "....        @@@@@@        ......................................................................................................."
echo "...   @@@@@@@    @@@@@@@    ....................................................................................................."
echo "..  @@+   .        .    @@. ...........      ....................     .........    ...      ........      ......................."
echo "..  @@     @@@@@@@@     @@= ...........  @@@ .................... @@@  .......      .. =@@= ........ +@@@ ......................."
echo "     @@  @@        @@: @@     ....       @@@                      @@@          #@@     :@@                .                      "
echo " :@@@@  @=   .....   @  @@@@* ...  @@@@@@@@%  .@@@@@@    @@@@@@@  @@@   @@@+@@@@@@@@@@  @@@@@@@@  @@@@@@@ .  @@@@@@@@   @@@@@@@@@"
echo " @@    *@  ......... %@    @@ ... @@@*  @@@* @@@   @@@  @@*   @@@ @@@ .@@@     +@@      @@@  @@@.     @@*    @@@   @@+ @@@   @@@@"
echo " @@    *@  ......... %@    @@ ... @@@    @@= @@@@@@@@@@ @@@@@     @@@@@@       =@@      @@    @@-     @@+    @@:   @@: @@     @@@"
echo " +@@@@  @:  ......   @  @@@@# ... @@@    @@= @@%            @@@@@ @@@@@@@   .. @@@      @@    @@:     @@     @@%   @@: @@@    @@@"
echo "     @@  @@        @@- @@     ... @@@@#@@@@@ #@@@  @@@ :@@@   @@@ @@@   @@@  . #@@@=@@ .@@:   @@= @@=+@@@-@: @@@   @@%  @@@@@@@@@"
echo "..  @@     @@@@@@@@-    @@: .....   @@@@-@@@   @@@@@=    +@@@@@-  @@@    @@@..   @@@@@ -@@+   @@* @@@@@@@@@@ @@@   @@@        @@@"
echo "..  @@                  @@: ......                    ..              .      ..                                        @@@@@@@@@ "
echo "...   @@@@@@@    @@@@@@@.   ..........................................................................................           "
echo "....        @@@@@@.       ...............................................................................................      .."
echo "..........   =%@+   ............................................................................................................."
echo "...........        .............................................................................................................."

#Step 1 Update/Upgrade Pi to newest Version
echo "................................................................................................................................."
echo "Step 1: Update/Upgrade Pi to newest Version"
echo "................................................................................................................................."

sudo apt update
sudo apt full-upgrade -y


echo "................................................................................................................................."
echo "Step 2: Check and install dependencies (node/npm/electron/electron-vite)"
echo "................................................................................................................................."

# Check and Install nvm as a base for the deskthing-server
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node
nvm install-latest-npm


echo "................................................................................................................................."
echo "Step 3: Clone ItsRiprod/DeskThing and add dependencies"
echo "................................................................................................................................."

# Git clone DeskThing
git clone https://github.com/ItsRiprod/DeskThing $HOME/DeskThing

chmod 777 -R $HOME/DeskThing

cd $HOME/DeskThing/DeskThingServer

# Check and Install dependencies for running deskthing-client locally
npm install electron electron-vite @vitejs/plugin-react tailwindcss postcss autoprefixer vite

node -v > .nvmrc
nvm use


echo "................................................................................................................................."
echo "Step 4: Autostart DeskThing"
echo "................................................................................................................................."

# Create the client_sandbox folder
cd ..
mkdir client_sandbox
cd client_sandbox

node -v > .nvmrc
nvm use

# Create package.json for the sandbox
cat <<EOF > package.json
{
  "name": "client_sandbox",
  "version": "1.0.0",
  "description": "",
  "main": "starter.js",
  "scripts": {
    "start": "electron starter.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "electron": "^33.3.1"
  }
}
EOF

# 1) Create a local loading.html with an indefinite spinner & message
cat <<EOF > loading.html
<html>
  <head>
    <title>Loading DeskThing</title>
    <style>
      body {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100vh;
        margin: 0;
        background: #fafafa;
        font-family: sans-serif;
      }
      h1 {
        margin-bottom: 10px;
      }
      .spinner {
        width: 50px;
        height: 50px;
        border: 6px solid #ccc;
        border-top: 6px solid #0078d7;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-bottom: 20px;
      }
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      p {
        font-size: 1.1em;
        color: #333;
        text-align: center;
        max-width: 300px;
      }
    </style>
  </head>
  <body>
    <h1>Loading DeskThing...</h1>
    <div class="spinner"></div>
    <p>If this screen does not change in 2 minutes, <br>please restart the Raspberry Pi.</p>
  </body>
</html>
EOF

# 2) Update starter.js to first show loading.html, then attempt the server
cat <<EOF > starter.js
const { app, BrowserWindow, globalShortcut } = require('electron');
const path = require('path');

let mainWindow;
let intervalId;
let isPageLoaded = false;

// We'll try loading the server at this URL
const urlToLoad = "http://localhost:8891/";

// 2-minute timeout in milliseconds
const LOAD_TIMEOUT_MS = 2 * 60 * 1000;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1920,
    height: 1080,
    fullscreen: true,
    alwaysOnTop: true,
    webPreferences: {
      nodeIntegration: true,
    },
  });

  // Immediately show our local loading screen
  mainWindow.loadFile(path.join(__dirname, 'loading.html'));

  // Start a 2-minute timer; if server content isn't found, remain on loading screen
  const loadTimeoutId = setTimeout(() => {
    if (!isPageLoaded) {
      console.log('Server did not load after 2 minutes. Staying on loading screen.');
      clearInterval(intervalId); // Stop further attempts
    }
  }, LOAD_TIMEOUT_MS);

  // Attempts to load the server URL and check if content is present
  function checkAndReload() {
    if (!mainWindow || isPageLoaded) return;

    // Try loading the server
    mainWindow.loadURL(urlToLoad);

    // Check if the page is still empty
    mainWindow.webContents.executeJavaScript('document.body.innerHTML.trim()')
      .then((content) => {
        if (!content) {
          console.log('Page is empty, will retry in 5 seconds...');
        } else {
          console.log('Page content detected. Stopping reload checks.');
          isPageLoaded = true;
          clearInterval(intervalId);
          clearTimeout(loadTimeoutId);
        }
      })
      .catch((error) => {
        console.error('Error checking page content:', error);
      });
  }

  // Every 5 seconds, try loading the server if still empty
  intervalId = setInterval(checkAndReload, 5000);

  // Close the window if the 'Esc' key is pressed inside the webContents
  mainWindow.webContents.on('keydown', (event) => {
    if (event.key === 'Escape') {
      app.quit();
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
    if (intervalId) {
      clearInterval(intervalId);
    }
    clearTimeout(loadTimeoutId);
  });
}

app.whenReady().then(() => {
  // Add a 60-second delay
  setTimeout(() => {
    createWindow();

    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) {
        createWindow(); // Recreate the window if all windows are closed (macOS)
      }
    });

    // Register global shortcut (optional) to close the app on 'Esc'
    globalShortcut.register('Esc', () => {
      app.quit(); // Close the application when 'Esc' is pressed
    });
  }, 60000); // 60 seconds delay
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit(); // Quit the app if all windows are closed (except macOS)
  }
});
EOF

# Initialize NPM and ensure electron is installed
npm init -y
npm install electron

# Create user-level systemd services
mkdir -p $HOME/.config/systemd/user

cat <<EOF > $HOME/.config/systemd/user/deskthing.service
[Unit]
Description=DeskThing Server Starter
After=network.target

[Service]
Type=simple
WorkingDirectory=$HOME/DeskThing/DeskThingServer
ExecStart=$HOME/.nvm/nvm-exec npm start
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat <<EOF > $HOME/.config/systemd/user/sandbox.service
[Unit]
Description=DeskThing Client Starter
After=deskthing.service
Requires=deskthing.service

[Service]
Type=simple
WorkingDirectory=$HOME/DeskThing/client_sandbox
ExecStart=$HOME/.nvm/nvm-exec npm start
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Reload systemd for user services
systemctl --user daemon-reload

# Enable services to start on boot (at user login)
systemctl --user enable deskthing.service
systemctl --user enable sandbox.service

# Start services immediately
systemctl --user start deskthing.service
systemctl --user start sandbox.service

echo "Setup finished!"
