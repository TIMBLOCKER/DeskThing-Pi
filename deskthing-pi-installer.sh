#!/bin/bash
. $HOME

#Execute on ~/
#This installer will download and create all neccessary components to run DeskThing on Rapsberry Pi 4

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

#Check and Install nvm as a base for the deskthing-server
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node


nvm install-latest-npm


echo "................................................................................................................................."
echo "Step 3: Clone ItsRiprod/DeskThing and add dependencies"
echo "................................................................................................................................."

#Git clone DeskThing
git clone https://github.com/ItsRiprod/DeskThing $HOME/DeskThing

chmod  777  -R  $HOME/DeskThing

cd $HOME/DeskThing/DeskThingServer

#Check and Install dependencies for running deskthing-client locally
npm install electron electron-vite @vitejs/plugin-react tailwindcss postcss autoprefixer vite

node -v > .nvmrc

nvm use

echo "................................................................................................................................."
echo "Step 4: Autostart DeskThing"
echo "................................................................................................................................."


cd ..

mkdir client_sandbox

cd client_sandbox

node -v > .nvmrc

nvm use

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

cat <<EOF > starter.js 
const { app, BrowserWindow, globalShortcut } = require('electron');
let mainWindow;
let intervalId;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1920, // Set the width of the window
    height: 1080, // Set the height of the window
    fullscreen: true, // Set the window to fullscreen
    alwaysOnTop: true, // Ensure the window is always on top
    webPreferences: {
      nodeIntegration: true, // Enable node integration (if needed)
    },
  });

  const urlToLoad = "http://localhost:8891/";

  // Function to refresh the page if the content is empty
  function checkAndReload() {
    if (!mainWindow) return;

    mainWindow.webContents.executeJavaScript('document.body.innerHTML.trim()')
      .then((content) => {
        if (!content) {
          console.log('Page is empty, reloading...');
          mainWindow.loadURL(urlToLoad);
        } else {
          console.log('Page content detected, stopping reload checks.');
          clearInterval(intervalId); // Stop the interval once content is loaded
        }
      })
      .catch((error) => {
        console.error('Error checking page content:', error);
      });
  }

  mainWindow.loadURL(urlToLoad);

  // Start interval to check page content every 5 seconds
  intervalId = setInterval(checkAndReload, 5000);

  // Close the window if the 'Esc' key is pressed
  mainWindow.webContents.on('keydown', (event) => {
    if (event.key === 'Escape') {
      app.quit(); // Close the application when the 'Esc' key is pressed
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null; // Cleanup when the window is closed
    if (intervalId) {
      clearInterval(intervalId); // Ensure the interval is cleared
    }
  });
}

app.whenReady().then(() => {
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
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit(); // Quit the app if all windows are closed (except macOS)
  }
});
EOF

npm init -y

npm install electron 

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

systemctl --user daemon-reload

systemctl --user enable deskthing.service
systemctl --user enable sandbox.service

systemctl --user start deskthing.service
systemctl --user start sandbox.service


echo "Setup finished!"

