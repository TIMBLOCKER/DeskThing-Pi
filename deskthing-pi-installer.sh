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
echo "Step 3: Clone TIMBLOCKER/DeskThing-Pi and add dependencies"
echo "................................................................................................................................."

# Git clone DeskThing
git clone -b rawLaunch --single-branch https://github.com/TIMBLOCKER/DeskThing-Pi $HOME/DeskThing

chmod 777 -R $HOME/DeskThing

cd $HOME/DeskThing/DeskThingServer

# Check and Install dependencies for running deskthing-client locally
npm install electron electron-vite @vitejs/plugin-react tailwindcss postcss autoprefixer vite

node -v > .nvmrc
nvm use

echo "................................................................................................................................."
echo "Step 4: Autostart DeskThing"
echo "................................................................................................................................."

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

# Reload systemd for user services
systemctl --user daemon-reload

# Enable services to start on boot (at user login)
systemctl --user enable deskthing.service

# Start services immediately
systemctl --user start deskthing.service

echo "Setup finished!"