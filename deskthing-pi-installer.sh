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
apt update
apt full-upgrade -y

#Check and Install rpi-connect for remote access (can be skipped if connected with physical access)
if which rpi-connect > /dev/null
    then
        echo "rpi-connect is installed - no installation needed"
    else
        apt install rpi-connect
    fi
rpi-connect on


#Check and Install node as a base for the deskthing-server
if which node > /dev/null
    then
        echo "node is installed - no installation needed"
    else
        apt install nodejs -y
    fi

#Check and Install npm as a package manager for downloading repo
if which npm > /dev/null
    then
        echo "node is installed - no installation needed"
    else
        apt install npm -y
    fi

#Check and Install electron-vite for running deskthing-client locally
if which electron-vite > /dev/null
    then
        echo "electron-vite is installed - no installation needed"
    else
        npm install electron-vite
        npm install electron
    fi    


#Git clone DeskThing
git clone https://github.com/ItsRiprod/DeskThing DeskThing

chmod -R a+rwx ~/DeskThing
chmod -R a+rwx ~/node_modules

#Change into DeskThing Server Directory
cd DeskThing/DeskThingServer
ifconfig #get IP Adress
sudo -u $USER npm run dev --host #DeskThing can be accessed from outside with IP-Adress and Port 8891

#Display DeskThing in FullScreen on RPi
DISPLAY=:0.0 chromium-browser --noerrdialogs --incognito --kiosk http://localhost:8891/
