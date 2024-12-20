

![DeskThingPi-Logo](https://github.com/TIMBLOCKER/DeskThing-Pi/blob/ac63a235907ffbdf23b503e45caf5946f0584b99/readme_images/deskthing-PI.png)
# DeskThing-Pi 

### What brought us here?
Some days ago I was stumbling upon a wonderful project by the very talented [ItsRiprod](https://github.com/ItsRiprod) who tried to save the ever doomed Spotify CarThing from becoming total E-Waste. Unfortunately the opposite seemed to be happening. Everyone now wants to have an EOL CarThing to be able to run DeskThing on it.

Rather than trying to get my hands on one of these, I wanted to get it running on my Raspberry Pi 4. So this is the official Repo of DeskThing-Pi.

## Want to get started?⚙️
#### Installing DeskThingPI
Just copy the Link into your command line and execute the command:

    sudo bash -c  "$(curl -sL https://raw.githubusercontent.com/TIMBLOCKER/DeskThing-Pi/refs/heads/main/deskthing-pi-installer.sh)"

#### Starting DeskThingServer
After that you have everything to get started. With the command: ``npm run dev --host`` in your ``~/DeskThing/DeskThingServer/`` directory you can start the server and install your Apps as needed.

#### Starting DeskThingClient
After the Server successfully started you can install the client via the Server App. When the install process is finished you can easily start you DeskThingPi by typing:
``DISPLAY=:0.0 chromium-browser --noerrdialogs --incognito --kiosk http://localhost:8891/`` in your command line. This will open the DeskThingPi in Kioskmode.

> Attention: You can always exit the Kiosk Mode and go back to the DeskThingServer Settings by pressing ``ALT`` and ``SPACE`` on the keyboard.

## Current Limitations 
I'd really like to get my hands on one of the RPI-Touchpads so that I can test and verify the functionality of the hardware. Accordingly it would be really awesome if DesThing could be compatible with a normal RotaryEncoderKnob and some off the shelve buttons, so that the CarThing dependency is eliminated.

Regarding this topic, all help is appreciated.
