\# Melee Mayhem Codex Instructions



\## Project



Melee Mayhem is a Godot 4.7 2D top-down chase/tag prototype.



Project root:

D:\\Melee Mayhem\\melee-mayhem



Godot executable:

D:\\Godot\_v4.7-stable\_win64.exe



Use this command for validation:

\& "D:\\Godot\_v4.7-stable\_win64.exe" --headless --path . --quit-after 1



\## Core Rules



This is currently a 2D chase/tag prototype.



Do not add:

\- 3D nodes

\- combat

\- attacks

\- blocking

\- jumping

\- dodging

\- RigidBody movement

\- force-based physics

\- rope physics

\- destructible systems

\- multiplayer

\- online features



Movement must be scripted and deterministic.



Use:

\- CharacterBody2D for the player

\- move\_and\_slide() only for collision resolution

\- Input Map actions for all input

\- DualSense only as a standard gamepad



\## Scale



1 design unit = 100 Godot pixels.



Arena:

\- 2400 x 2400 px

\- center at 0,0

\- bounds from -1200 to 1200



Player:

\- 60 x 60 px

\- half-size 30 px

\- center must clamp from -1170 to 1170 on both axes



Base speed:

\- 6 units/sec

\- 600 px/sec



\## Approved Input Actions



Only use these unless the design spec is updated:



\- move\_left

\- move\_right

\- move\_up

\- move\_down

\- boost

\- cancel

\- reset

\- switch\_archetype

\- toggle\_debug



\## Current Stage Discipline



Implement one stage at a time.



Before implementing a stage:

\- read DESIGN\_SPEC.md

\- state the files you expect to change

\- state the acceptance checks

\- do not broaden scope



After implementing:

\- run Godot headless validation

\- report files changed

\- report any errors

\- report how to manually test



\## Stage Roadmap



Stage 0:

\- tool and controller validation



Stage 1:

\- one player block

\- flat square arena

\- deterministic movement

\- boundary clamp

\- debug HUD



Stage 2:

\- one shared generic boost system only

\- configurable boost duration

\- configurable top speed

\- configurable acceleration time

\- configurable cooldown

\- configurable steering strength

\- distance traveled during boost

\- debug display for boost state

\- no archetype-specific features yet



Stage 3:

\- five chase profiles using the shared boost system



Stage 4:

\- chaser and runner



Stage 5:

\- map features: walls, low barriers, breakable obstacles, hazards, tunnel routes



Stage 6:

\- archetype-specific map interactions



\## Tone of Work



Prefer minimal architecture.

Do not create extra scripts until they are justified.

Do not invent combat systems.

Do not interpret Godot default 3D settings as permission to make the project 3D.

