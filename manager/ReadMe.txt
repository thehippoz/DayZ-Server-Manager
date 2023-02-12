DayZ Server Manager by Ben Barbre (benbarbre@gmail.com) Jan, 2023 https://github.com/thehippoz/DayZ-Server-Manager

It's a DayZ tool that restarts your server and updates mods realtime while taking care of crashing. It also has a keepalive written in for remote desktop users. It uses DaRT for rcon and steamcmd to update mods. https://github.com/TheGamingChief/DaRT/ https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip


Directions


-=-=-=-=-=-=-=-=-=--=--=-=-=-=-



Extract steamcmd.exe into your \Steam folder. It's probably in \Program Files (x86). Extract this package to the root of your server. DaRT can go anywhere as you have to manually run that first before Manager. Open the Steam folder using file explorer (Right click in the folder holding shift and click open command window) and type steamcmd. Now type login <user> using your steam account name. Finish up the auth questions there and exit. Now setup DaRT and adjust the settings for autoconnect. 

The manager is setup by editing Configure.ini. You can set a new tray icon for each server by replacing running.ico. If everything is configured correctly in the ini, launch the server and then run Dart, connect. If the rcon is working, run manager and it should handle things from there.

You should update all mods manually before running the first time. The database is created in Mods.ini (delete it and it will be re-created). There are no registry entries made, no api key and UAC isn't needed. You can recompile the ahk but keep the credits. Adding functions to this should be easy to do for those who like to program. The sky's the limit, roaming traders, randomized spawns to keep the playerbase guessing.



Editing
Configure.ini


-=-=-=-=-=-=-=-=-=--=--=-=-=-=-

ServerName - The name of your current map or whatever you want to put in here. It's the titlebar of the manager so you can run multiple servers with different titles and tray icons using running.ico. Example: Deer Isle. If you do run multiple, make a Dart copy and rename Dart.exe for each server run. Change the DartName field below in each copy of manager. Multiple servers is untested and I do see conflicts happening with rcon being used at the same time, or a mod being updated at the same time. That's what's great about open source, I'm sure someone could fix it.

DayZServer - Path to the root of your server. Example: C:\Program Files (x86)\Steam\steamapps\common\DayZServer\

Startup - The name of the bat file used to startup the server. Manager will find the mods used in this file. It looks for this in DayZServer above. Example: StartServer.bat

SteamWorkshopFolder - Path to where steamcmd downloads new updates. Example: C:\Program Files (x86)\Steam\steamapps\workshop\content\221100\

DartName - The running exe name of DaRT found in the task manager. Example: DaRT.exe

Steamuser - The username of the steam account the server runs under. It should be the same as the username used in steamcmd. Example: budd8works

ShutdownHours - The server will restart at the top of each hour listed here. List is in military time. Example: 0,3,6,9,12,15,18,21

MinBeforeShutdown - Number of minutes before the hours (listed above) that the server is scheduled to restart. This value will vary depending on the speed of your restart. Set this to the number of minutes it takes for a full restart. Example: 5

CheckForUpdatedMods - This is the number in minutes it could potentially take to detect a mod has been updated and issue a shutdown, update, and finally restart. Divide this number * 60 by the number of mods you're running, and that's the time in seconds to check each mod (if it's been updated) on steam. The main purpose is to stop spamming steam since there is no api key used. Example: 10

MinimumStartupTime - This is the time in minutes the manager will remain idle after launch. No point other than to annoy you but it's nice to have a delay in case you forgot to launch the server or Dart, ect. Example: 1

CancelModUpdatesBeforeShutdown - Cancel all mod update checks this many minutes before a server restart. Add together CancelModUpdatesBeforeShutdown + MinBeforeShutdown for the actual time. If this time is too short, part of the restart countdown might not show. Example: 25

ModUpdateWarning - The number of seconds to issue a warning to players in the server before a mod update. This will be sent to the server with global say immediately. Example: 120

CountdownSeconds - The time in seconds to start repeating the warning (every 10 seconds). This number should be divisable by 10 and less than ModUpdateWarning above. Example: 90

MessageShutdown - The message sent during a restart. #tms# is substituted for minutes here. Example: Server is restarting in #tms#

MessageUpdatedMods - The message sent during an update. #mod# is substituted for the mod name being updated. #tms# is substituted for seconds here. Example: Updating pbo #mod#. Restarting in #tms#

ShutDownDialog - It's the position of the error button used to close out DayZ when the server crashes on restart. Use the manager to hover over this button and get the x,y coordinates when set to 0,0. Will vary depending on the screen resolution. Example: 502,384

DartSayBox - Manager uses a technique to scan pixels on the screen. It uses the color of the line around the send box in DaRT to determine if it's ready for input. It does this by scanning vertically from this x,y value and looks for blue outline (win10/server). Hover on, or just below the grey line above the say box within 10 pixels of the blue when active and enter the value here. Example: 300,700

DartSayBoxColor - This is the hex color used to determine if the say box is ready for input. There are a couple of debug files Manager generates for help in finding the value in the manager folder > Pos.png and HexColorsFound.txt  Example: 78D700



Notes


-=-=-=-=-=-=-=-=-=--=--=-=-=-=-


Manager tries to keep Dart maximized when possible. It also runs with remote desktop which can be a pain without something to keep it active. There is a routine run every 30 seconds server side to act like there's activity. It also checks if the server is crashed every 5 minutes and will automatically restart.

I also added this registry key client side (manually) to keep the screen active while rdp is minimized:

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Terminal Server Client]
"RemoteDesktop_SuppressWhenMinimized"=dword:00000002

You could run remote software like Teamviewer instead. It allows both the server and client to run without locking the screen. The problem I have is it connects to the writer and tries to send itself updates until you block it. Then you're limited to lan. Security is a thing I think.

Have fun with it. You can try omega manager too. It seems that's where all the redditors are but has the same problem, closed source and you can't add your own code to expand your server like roaming traders without the need for AI or randomizing enemy spawns between restarts. Sky's the limit really. Manager stores its mod update logs in \profiles.

To do: There is currently a thing where mods aren't recorded as updated with the current year on steam. So if the year rolls over, it will trigger an update on all mods updated last year. The workaround currently is to delete the mods.ini on Jan 1st. I will probably fix this in a future update. There is also an issue if you forget to connect Dart to the server, it will end up looping trying to find an active box for rcon.

Credits


-=-=-=-=-=-=-=-=-=--=--=-=-=-=- 


- TheGamingChief for DaRT
- every1knowsdave on YouTube for his .bat script on using steamcmd for updating mods without an api key
- AutoHotKey v1.1
- My birds that passed \'/\'/\"/ Rip you fat motherfucker and lovely soul of a partner.

I can still code after covid which drops your iq 20 points and messed up my load shot xD Maybe not high high level like last year, but oh well.
