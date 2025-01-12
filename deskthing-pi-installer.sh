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
apt update
apt full-upgrade -y

echo "................................................................................................................................."
echo "Step 2: Check and install dependencies (node/npm/electron/electron-vite)"
echo "................................................................................................................................."


#Check and Install node as a base for the deskthing-server
if which nodejs > /dev/null
    then
        echo "nodejs is installed - No installation needed"
    else
    echo "................................................................................................................................."
    echo "Installing nodejs"
    echo "................................................................................................................................."
        apt install nodejs -y
    fi

#Check and Install npm as a package manager for downloading repo
if which npm > /dev/null
    then
        echo "npm is installed - No installation needed"
    else
    echo "................................................................................................................................."
    echo "Installing npm"
    echo "................................................................................................................................."
        apt install npm -y
    fi
  

echo "................................................................................................................................."
echo "Step 3: Clone ItsRiprod/DeskThing and add dependencies"
echo "................................................................................................................................."

#Git clone DeskThing
git clone https://github.com/ItsRiprod/DeskThing DeskThing

cd DeskThing/DeskThingServer

#Check and Install dependencies for running deskthing-client locally
npm install electron electron-vite @vitejs/plugin-react tailwindcss postcss autoprefixer vite

echo "................................................................................................................................."
echo "Step 4: Autostart DeskThing"
echo "................................................................................................................................."


cd ..


mkdir client_sandbox

cd client_sandbox

npm init -y

cat > package.json <<EOF
{
  "name": "sandbox_client",
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

cat > starter.js <<EOF
const { app, BrowserWindow, globalShortcut } = require('electron');
let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1920,  // Set the width of the window
    height: 1080, // Set the height of the window
    fullscreen: true, // Set the window to fullscreen
    webPreferences: {
      nodeIntegration: true, // Enable node integration (if needed)
    },
  });

  mainWindow.loadURL("http://localhost:8891/"); // Load the URL

  // Close the window if the 'Esc' key is pressed
  mainWindow.webContents.on('keydown', (event) => {
    if (event.key === 'Escape') {
      app.quit(); // Close the application when the 'Esc' key is pressed
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null; // Cleanup when the window is closed
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

 // Register global shortcut (optional) to close the app on 'Esc'
  globalShortcut.register('M', () => {
   mainWindow.minimize();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit(); // Quit the app if all windows are closed (except macOS)
  }
});
EOF

cd ..
cd ..
$DESKPATH="$(realpath ".")"
cd $DESKPATH/.config/systemd/user/

cat > $DESKPATH/.config/systemd/user/deskthing.service <<EOF
[Unit]
Description=DeskThing Server Starter
After=network.target

[Service]
Type=simple
WorkingDirectory=$DESKPATH/DeskThingServer
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > $DESKPATH/.config/systemd/user/sandbox.service <<EOF
[Unit]
Description=DeskThing Client Starter
After=deskthing.service
Requires=deskthing.service

[Service]
Type=simple
WorkingDirectory=$DESKPATH/client_sandbox
ExecStart=/usr/bin/npm start
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


