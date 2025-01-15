<p align="center">
    <img width="500" src="https://github.com/TIMBLOCKER/DeskThing-Pi/blob/ac63a235907ffbdf23b503e45caf5946f0584b99/readme_images/deskthing-PI.png" alt="DeskThing-Pi logo">
</p>

# DeskThing-Pi 

### What brought us here?
Some days ago I was stumbling upon a wonderful project by the very talented [ItsRiprod](https://github.com/ItsRiprod) who tried to save the ever doomed Spotify CarThing from becoming total E-Waste. Unfortunately the opposite seemed to be happening. Everyone now wants to have an EOL CarThing to be able to run DeskThing on it.

Rather than trying to get my hands on one of these, I wanted to get it running on my Raspberry Pi 4. So this is the official Repo of DeskThing-Pi.

## Want to get started?⚙️
### Prequisities
As this project is still in a really early stage, I can only confirm that things are working with the current checked hardware. So you need to have some setup already done to be able to start:

#### Mandatory
 - Hardware: Raspberry Pi 4 (I use the 4GB  Version but others should work as well)
 - Standard Raspberry Pi OS (64 Bit) freshly installed (I prefer to use the Raspberry Pi Imager to flash the OS)
> Attention: Here it is essential that you have installed the GUI Version of Raspbian because otherwise you wil get some errors with the build pipeline of DeskThingServer.

#### Useful but not entriely necessary

 - SSH enabled
 - local Hostname set to something you remember (e.g. `raspberrypi.local`)
 - WIFI enabled and already provided with SSID and Password
 - Language Settings correctly set
 - Configured User with known Password
 - Access with RPI-Connect (to enable use `rpi-connect on` and `rpi-connect signin`)

## Installing DeskThingPI
### Connect to your Pi and run setup
If you've set everything according up correctly you should be able to SSH into your Pi with the aforementioned User and Password combination. You can then just copy the Link into your command line and execute the command:

    bash -c  "$(curl -sL https://raw.githubusercontent.com/TIMBLOCKER/DeskThing-Pi/refs/heads/main/deskthing-pi-installer.sh)"

### Starting DeskThingClient
After the Setup has completed you should have one fullsize white window and the DeskThingServer Console running. Now you can install the client via the Server App. Just go to `Clients > Download Client`. After the download is completed just click `Refresh Client` and press `ESC`. This will trigger the Pi to restart the browser for the Client App. This will open the DeskThingPi in Kioskmode.


> Attention: You can always exit the Client App and go back to the DeskThingServer Settings by pressing ``ESC`` on the keyboard. The Client App will restart automatically after 10 Seconds.

## Current Limitations 
In the folowing weeks I will experiment with off the shelve touch displays so that we can create a list of known-good parts für the DeskThingPi. The final Goal is to eliminate the need of the CarThing-Hardware and make it so that people can easyly install the project themselves.

Regarding this topic, all help is appreciated. Just DM me on DeskThings Discord.
