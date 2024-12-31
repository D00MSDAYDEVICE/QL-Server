# QLServer

This project was originally created by dngrtech for the quick deployment of Thunderdome Quake Live servers, but can be beneficial to any server admin.
I have updated some workshops since it's original release and have updated/edited the files here to match.
It includes popular plugins, factories, sound and map workshop numbers.
Many plugins are included for convenience but only those set in your config using the qlx_plugins cvar are loaded.

To deploy a Quake Live dedicated server:
1. Deploy a new Ubuntu server or use existing.
2. Login as root, install github cli tools:
```
sudo apt update
sudo apt install gh
```
4. Authenticate to github.com:
```
gh auth login
```
6. Checkout this repository to root's home folder: 
```
git clone https://github.com/D00MSDAYDEVICE/QLServer.git
```
8. cd to repo folder, edit server1.cfg, server2.cfg, server3.cfg 
9. Set init script to be executable:
```
chmod +x init.sh
```
11. Execute init.sh, follow installation wizard
12. Wait for docker to pull images and start the service. To check service status:
```
systemctl status docker-compose-qlds.service
```
13. Harden ssh access by copying your ssh public key in the /home/$username/.ssh/authorized_keys 

## Project files and directories structure
```
├── data                        > main folder for persistent data
│   ├── baseq3
│   │   └── chatlogs            > chatlogs folder
│   │       ├── server-1
│   │       │   └── chat.log
│   │       ├── server-2
│   │       │   └── chat.log
│   │       └── server-3
│   │           └── chat.log
│   ├── minqlx-plugins          > minqlx plugins folder
│   ├── scripts                 > factories folder
│   └── steamapps               > all downloadable contents folder
├── docker-compose.yaml         > main docker-compose file
├── Dockerfile                  > file to build main qlds docker image
├── entrypoint.sh               > commands to be executed on qlds startup (adjusting this requires rebuilding docker image)
├── init.sh                     > main init script for qlds deployment
├── mappool.txt                 > main default mappool file for td7 clan arena
├── mappool_ca_rockets.txt      > custom mappool for rocket no splash damage factory (not used in default deployment)
├── mappool_ca.txt              > custom mappool for lg antilag factory  (not used in default deployment)
├── mappool_ffa_fun.txt         > custom mappool for ffa no self damage all weapons and unlim ammo factory (not used in default deployment)
├── mappool_ffavamp.txt         > custom mappool for lg antilag factory with rocket and rail (not used in default deployment)
├── README.md                   > this file
├── redis                       > redis conf file folder
│   ├── Dockerfile              > redis dockerfile
│   └── redis.conf              > redis config file
├── server1.cfg                 > server-1 config file (server-1 is specified as a first container in the docker-compose.yaml configuration)
├── server2.cfg                 > server-2 config file (server-2 is specified as a second container in the docker-compose.yaml configuration)
├── server3.cfg                 > server-3 config file (server-3 is specified as a third container in the docker-compose.yaml configuration)
├── utils
│   ├── rsync_client_setup.sh   > mainly used for testing rsync client to download content from tx server
│   └── rsync_setup.sh          > script to set up rsync server part on tx server
└── workshop.txt                > main workshop.txt file, edit it to add workshop items
```

# QLDS management

Edit server1.cfg, server2.cfg, server-3.cfg and workshop.txt to adjust all three servers' configuration.
Edit factories in /home/$username/QLServer/data/scripts
Edit minqlx plugins' scripts in /home/$username/QLServer/data/minqlx-plugins
To stop all qlds docker containers use zsh alias "qldsdown", to start use "qldsup", to restart use "qldsrestart".
Server logs are located in /home/$username/QLServer/data/baseq3/chatlogs/server-(1..3) .

# Some included plugins (Beyond minqlx)

aliases<br>
branding<br>
clanmembers<br>
commlink<br>
intermission<br>
kills<br>
listmaps<br>
balance<br>
mybalance<br>
onjoin<br>
players_db<br>
player_info<br>
restartserver<br>
specall<br>
specqueue<br>
uberstats<br>


#  Workshops

The current list of workshopd include the following:<br>
2907206859	\\ Thunderdome Servers Workshop<br>
620087103		\\ Funny Sounds Pack for Minqlx<br>
1733859113	\\ West Coast Crew Sounds<br>
585892371		\\ PRESTIGE WORLDWIDE SOUNDHONKS<br>
572453229		\\ Duke Nukem Voice Sound Pack<br>
2377955827	\\ Doomsday's Sound Pack<br>
3357334482		\\ Doomsday's Sound Pack II<br>
3372915886		\\ Doomsday's Sound Pack III<br>
2920816724	\\ Doomsday's Intermissions Pack<br>
2955830332	\\ Fullbright model<br>
557591894		\\ RA3MAP1 (thunderstruck, evolution, theater of boredom, canned heat)<br>
558200805		\\ RA3MAP2 (another 4 maps we already have but originals)<br>
607909342		\\ RA3MAP2pp ShakenNotStirredPP<br>
561613916		\\ RA3MAP3<br>
561815150		\\ RA3MAP4<br>
561459991		\\ RA3MAP5<br>
553095317		\\ RA3MAP6<br>
561877295		\\ RA3MAP7<br>
551367534		\\ RA3MAP8<br>
551148976		\\ RA3MAP9<br>
550843679		\\ RA3MAP10<br>
562987267		\\ RA3MAP11<br>
605561819		\\ RA3MAP11pp (Overkillpp )<br>
1804860462	\\ RA3MAP12 <br>
550674410		\\ RA3MAP13<br>
1804890831	\\ RA3MAP14 (Newer, last updated Aug 2023)<br>
550575965		\\ RA3MAP15<br>
550566693		\\ RA3MAP16<br>
1804956548	\\ RA3MAP17 <br>
550003921		\\ RA3MAP18<br>
1804992817	\\ RA3MAP19 <br>
551229107		\\ RA3MAP20<br>
551699225		\\ RA3MAP21<br>
553088484		\\ RA3MAP22<br>
2358556636	\\ Uprise (xiri - January 2021)<br>
579950284		\\ Cow's Map<br>
597920398		\\ Fly on Rocket aka ts_ca1<br>
2790708234	\\ Fly on Rocket II<br>
740534444		\\ OkRemix - Revised<br>
1317503170	\\ Overchad<br>
1935100656	\\ overkeel<br>
3104458505	\\ Welcome to Hell<br>
562387741		\\ Lanphi 1 (Amphi Rebuild / Bug Fixes)<br>
2592514624	\\ Strain by geez louiz (Sept. 2021)<br>
3128296346	\\ 1v1r by Spike (January 2024)<br>
2887233117	\\ Spike's No Halls version<br>
3161885439	\\ 5quid by Spike (February 2024)<br>
3147966392	\\ Servitude Redux by Spike (February 2024)<br>
2888269948	\\ Twitchy's Nohalls (28 January 2024)<br>
3149546769	\\ NoHalls2 (Twitch's Version)<br>
3156001078	\\ Cannonball<br>
550850908		\\ Solitude<br>
564894881		\\ Storm maps<br>
584176488		\\ Charon maps<br>
577333309		\\ Nemesis (gcBloody's Workshop)<br>
2608153632	\\ RA3Mapkit1 - No Love Map<br>
3148145855	\\ Project Velocity - cure<br>
3145141306	\\ Project Velocity - sinister<br>
3142063028	\\ Project Velocity - furiousheights<br>
3137953080	\\ Project Velocity - lostworld<br>
3131176118	\\ Project Velocity - campgrounds<br>
3131173163	\\ Project Velocity - Bloodrun<br>
3130713028	\\ Project Velocity - aerowalk<br>