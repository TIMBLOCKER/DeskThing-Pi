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


#Check and Install rpi-connect for remote access (can be skipped if connected with physical access)
while true; do
    read -p "Do you wish to install rpi-connect for remote access [Y/N]? " yn
    case $yn in
        [Yy]* ) 
        if which rpi-connect > /dev/null
    then
        echo "rpi-connect is already installed - No installation needed!"
        rpi-connect on; 
        rpi-connect signin
    else
    echo "................................................................................................................................."
    echo "Installing rpi-connect and starting server"
    echo "................................................................................................................................."
        apt install rpi-connect
        rpi-connect on; 
        rpi-connect signin
    fi

break;;
        [Nn]* ) break;;
        * ) echo "Please answer Yy (Yes) or Nn (No).";;
    esac
done

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

#Check and Install electron-vite for running deskthing-client locally
if which electron-vite > /dev/null
    then
        echo "electron-vite is installed - No installation needed"
    else
    echo "................................................................................................................................."
    echo "Installing electron and electron-vite"
    echo "................................................................................................................................."
        npm install electron-vite
        npm install electron
    #Install  @vitejs/plugin-react as a dependency for the electron-vite    
    echo "................................................................................................................................."
    echo "Installing @vitejs/plugin-react (Dependency of electron-vite)"
    echo "................................................................................................................................."
        npm install @vitejs/plugin-react    
    fi    

echo "................................................................................................................................."
echo "Step 3: Clone ItsRiprod/DeskThing"
echo "................................................................................................................................."

#Git clone DeskThing
git clone https://github.com/ItsRiprod/DeskThing DeskThing


sudo chmod 777 -R ~/node_modules
sudo chmod 777 -R ~/DeskThing

#Change into DeskThing Server Directory
ifconfig #get IP Adress

echo "Setup finished!"
