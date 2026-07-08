# Melee Mayhem
## Chase Prototype Design Specification
### Version 0.1

## 1. Purpose

This prototype exists to answer one question:

> Is it fun to use distinct chase abilities to close distance, escape, and outplay another player in a small top-down arena?

The prototype is intentionally limited.

It is not yet:

- A battle royale
- A combat game
- A physics simulation
- A destructible-world sandbox
- A class progression system
- An online multiplayer game
- A final representation of the art style or camera

The first playable version is a top-down tag game built in Godot 4 using GDScript.

---

## 2. Technical Direction

### Engine

- Godot 4
- 2D project
- GDScript
- Compatibility renderer

### Development Environment

- VS Code
- Claude Code or Codex working from the project root
- Godot open for running, inspecting, and debugging scenes

### Project Root

`D:\Melee Mayhem\melee-mayhem`

### Core Technical Rule

Movement must be scripted and deterministic.

Do not use:

- Rigidbody-style forces
- Ragdolls
- Rope simulation
- Momentum physics
- Procedural destruction
- Complex animation systems

Collision detection is allowed and required. Physics simulation is not.

---

## 3. Prototype Structure

The prototype begins as a movement sandbox and develops in stages.

### Stage 0: Tool and Input Test

Requirements:

- Godot project opens
- Project runs successfully
- GDScript files open in VS Code
- Keyboard input works
- PS5 DualSense is detected as a standard gamepad
- Left-stick values can be displayed
- At least one controller button triggers a visible response

### Stage 1: Basic Movement

Requirements:

- One player block
- Flat square arena
- Fixed top-down camera
- Keyboard movement
- Left-stick movement
- Shared base movement speed
- Arena boundary collision
- Reset function
- Debug display for position and speed

### Stage 2: Generic Boost System

Requirements:

- One shared boost system
- Configurable duration
- Configurable top speed
- Configurable acceleration time
- Configurable cooldown
- Configurable steering strength
- Boost state display
- Remaining cooldown display
- Distance traveled during boost
- Expected straight-line distance

### Stage 3: Five Chase Profiles

Requirements:

- Breaker
- Hurdler
- Hazardborn
- Tunneler
- Chase
- Instant switching between profiles during testing
- All values loaded from tunable data resources
- No duplicated movement scripts per archetype

### Stage 4: Chaser and Runner

Requirements:

- One controlled chaser
- One runner
- Runner may initially use simple AI
- Touching the runner counts as a tag
- Tag resets player positions
- Role switching may be added later

### Stage 5: Arena Features

Requirements:

- Solid walls
- Low barriers
- Breakable obstacles
- Hazard zones
- Tunnel routes
- Clear debug colors for each environment type

### Stage 6: Archetype Features

Implement one at a time:

1. Chase
2. Breaker
3. Hurdler
4. Hazardborn
5. Tunneler

### Stage 7: Hurdler Hide Interaction

Requirements:

- Detect valid wall hiding
- Detect Hurdler rebound overshoot
- Confirm runner remains untagged
- Reduce runner’s remaining boost cooldown
- Default reduction: 25%
- No extra penalty applied to Hurdler

### Stage 8: Playable Tag Game

Requirements:

- Timed round
- Score
- Role swapping
- Character selection
- Two-controller support
- Restart flow
- Debug telemetry

---

## 4. Shared Movement Rules

### Base Speed

All characters begin with the same base movement speed.

Initial value:

- Base speed: 6 units per second

This value must be tunable.

### Input

Default controls:

| Action | DualSense | Keyboard |
|---|---|---|
| Move | Left Stick | WASD |
| Boost | R2 | Space |
| Cancel | Circle | Left Shift |
| Reset | Options | R |
| Switch Archetype | D-Pad | Number Keys |
| Toggle Debug | Triangle | F1 |

All actions must use Godot Input Map actions.

Do not hardcode controller button indices directly into movement scripts.

### Turning

Each archetype may have different steering strength during boost.

Normal movement steering should initially be identical across all characters.

### Boost Start

A boost begins when:

- The boost button is pressed
- The boost is not on cooldown
- The player is not in an invalid movement state

### Boost End

A boost ends when:

- Boost duration expires
- The boost is canceled, if canceling is allowed
- A character-specific rule ends it
- The player collides with an invalid obstacle
- The round resets

---

## 5. Tunable Boost Variables

Every archetype must expose the following variables:

### Shared Movement

- Base speed
- Normal acceleration
- Normal deceleration
- Normal turn rate

### Boost

- Boost duration
- Boost top speed
- Time to top speed
- Boost cooldown
- Boost steering strength
- Early cancel enabled
- Recovery duration
- Maximum distance
- Minimum cooldown floor

### Detection

- Tag radius
- Obstacle detection range
- Wall detection range
- Hazard detection range
- Tunnel entry detection range

### Status Effects

- Dizzy duration
- Tracking-loss duration
- Hazard bonus duration
- Post-tunnel tracking grace period

### Cooldown Modification

- Cooldown reduction percentage
- Remaining cooldown reduction
- Minimum cooldown after reduction

No balance value should be hardcoded inside the shared movement script.

---

## 6. Initial Chase Matrix

All numbers are first-pass tuning values.

| Archetype | Boost Duration | Top Speed | Time to Top Speed | Cooldown | Straight-Line Distance | Core Feature |
|---|---:|---:|---:|---:|---:|---|
| Breaker | 1.5 sec | 13 u/s | 0.4 sec | 10 sec | 18.1 units | Breaks through obstacles |
| Hurdler | 1.4 sec | 13 u/s | 0.3 sec | 16 sec | To be validated | Clears barriers and rebounds from walls |
| Hazardborn | 2.2 sec | 12 u/s | 0.7 sec | 13 sec | 24.3 units | Accelerates inside hazards |
| Tunneler | 1.1 sec | 15 u/s | 0.1 sec | 20 sec | 16.1 units | Uses tunnel routes and loses tracking |
| Chase | 0.9 sec | 11 u/s | 0.15 sec | 5 sec | 9.5 units | Frequent, highly controllable boost |

Straight-line distance must be calculated and displayed in the debug panel.

---

## 7. Archetype Definitions

## 7.1 Breaker

### Identity

Breaker closes distance by moving through obstacles rather than around them.

### Boost Behavior

During boost, Breaker can destroy valid breakable obstacles.

When Breaker destroys an obstacle:

- The obstacle is removed or disabled
- Breaker loses speed
- Breaker becomes Dizzy
- Breaker’s remaining boost cooldown is reduced

### Speed Scrub

Speed loss on impact must be tunable.

Initial placeholder:

- Speed loss: 40%

### Cooldown Reduction

Initial placeholder:

- Remaining cooldown reduction: 50%

This applies to remaining cooldown, not full base cooldown.

### Dizzy

Dizzy does not stun the player.

Dizzy affects:

- Steering strength
- Turn rate
- Directional precision

Initial placeholder:

- Dizzy duration: 0.75 seconds

### Breaker Tunable Variables

- Valid obstacle types
- Speed loss percentage
- Dizzy duration
- Dizzy steering penalty
- Remaining cooldown reduction percentage
- Minimum cooldown floor
- Breaker boost top speed
- Breaker boost duration
- Breaker boost steering

---

## 7.2 Hurdler

### Identity

Hurdler uses low barriers and walls to create new chase angles.

### Low Barrier Behavior

During boost, Hurdler may automatically clear valid low barriers.

Hurdler should not lose significant speed when clearing a valid low barrier.

### Wall Rebound

If Hurdler contacts a valid wall during boost, the player may activate one rebound dash.

The rebound:

- May be triggered once per boost
- Launches away from the wall
- Allows a direction selected within a 180-degree arc
- Is short
- Is faster than the initial boost
- Has near-immediate acceleration
- Is committed after activation
- Has no added miss penalty

Initial rebound values:

- Rebound duration: 0.45 seconds
- Rebound top speed: 18 units per second
- Rebound acceleration time: 0 seconds
- Rebound uses remaining boost time only if configured

### Overshoot

If the runner hides close to the wall and Hurdler rebounds past them, the chase continues naturally.

Hurdler receives no added penalty.

The lost position is the punishment.

### Successful Hide

A successful hide occurs when:

- The runner is within the configured wall-hide distance
- Hurdler activates the wall rebound
- Hurdler passes the runner without tagging them
- The runner remains untagged during the confirmation window

Reward:

- Reduce the runner’s remaining boost cooldown

Initial value:

- Remaining cooldown reduction: 25%

This reward may trigger once per Hurdler boost activation.

### Hurdler Tunable Variables

- Low-barrier clearance height
- Wall detection range
- Rebound direction arc
- Rebound duration
- Rebound top speed
- Rebound acceleration
- Rebound steering
- Wall-hide distance
- Overshoot distance
- Hide confirmation window
- Successful-hide cooldown reduction
- Minimum cooldown floor

---

## 7.3 Hazardborn

### Identity

Hazardborn turns dangerous terrain into a preferred chase route.

### Normal Boost

Initial values:

- Duration: 2.2 seconds
- Top speed: 12 units per second
- Time to top speed: 0.7 seconds
- Cooldown: 13 seconds

### Hazard Boost

While inside a valid hazard during boost:

- Top speed increases
- Acceleration increases
- Hazard movement penalties are reduced or ignored
- Straight-line distance increases

Initial hazard values:

- Hazard top speed: 16 units per second
- Hazard acceleration time: 0.25 seconds

### Hazard Entry

The bonus should begin when Hazardborn enters a valid hazard.

### Hazard Exit

The bonus should end when:

- Hazardborn exits the hazard, or
- A tunable grace period expires

### Hazardborn Tunable Variables

- Valid hazard types
- Hazard top speed
- Hazard acceleration
- Hazard immunity amount
- Hazard exit grace period
- Hazard steering
- Hazard boost visual state

---

## 7.4 Tunneler

### Identity

Tunneler uses designated under-wall routes and temporarily disappears from tracking.

### Tunnel Entry

Tunneler may enter only valid tunnel routes.

Tunnel surfaces must be clearly identified in debug view.

### Tunnel Movement

While inside a tunnel:

- Tunneler moves along the tunnel path
- Tunneler cannot collide with the wall above
- Tunneler cannot leave the tunnel except at valid exits
- Tunneler becomes untracked

### Tracking Loss

While untracked:

- No outline
- No directional marker
- No minimap marker
- No projected movement indicator

Initial value:

- Tracking loss lasts while inside the tunnel
- Optional post-exit grace period: 0.2 seconds

### Tunneler Tunable Variables

- Tunnel entry size
- Tunnel movement speed
- Tunnel steering
- Tunnel exit points
- Tracking-loss duration
- Post-exit tracking grace period
- Tunnel cooldown interaction

---

## 7.5 Chase

### Identity

Chase applies frequent and reliable pressure.

### Boost Behavior

Chase has:

- Shortest cooldown
- Shortest boost distance
- Strong steering
- Fast acceleration
- Low recovery
- No terrain-specific ability

### Chase Tunable Variables

- Boost duration
- Boost speed
- Acceleration time
- Cooldown
- Steering strength
- Cancel rules
- Recovery duration

Chase acts as the control case for the entire prototype.

If Chase consistently outperforms or feels better than the more complex archetypes, the special terrain mechanics may not be adding enough value.

---

## 8. Environment Types

Each environment type must have:

- A unique node type or component
- A clear debug color
- A visible label in debug mode
- Tunable interaction rules

### Solid Wall

- Blocks all normal movement
- Cannot be destroyed
- May allow Hurdler rebound
- May contain Tunneler route

### Low Barrier

- Blocks normal movement
- Can be cleared by Hurdler
- May be destroyed by Breaker
- Must have a consistent height classification

### Breakable Obstacle

- Blocks normal movement
- Can be destroyed by Breaker
- May scrub Breaker speed
- Must expose durability only if needed later

For the first prototype, destruction may simply disable the obstacle.

### Hazard Zone

- Applies a movement or danger penalty to most characters
- Improves Hazardborn boost performance
- Must be visually obvious

### Tunnel Route

- Available only to Tunneler
- Has defined entry and exit points
- Temporarily disables tracking

---

## 9. Tag Rules

A tag occurs when:

- Chaser enters the configured tag radius of the runner
- Neither player is in an invalid state
- No wall blocks valid contact

Initial tag behavior:

- Display `TAG`
- Freeze briefly if needed for readability
- Reset positions
- Increment score
- Optionally swap roles

Initial tag radius must be tunable.

---

## 10. Debug Requirements

The debug panel must display:

- Current archetype
- Player position
- Current speed
- Base speed
- Boost state
- Boost elapsed time
- Boost time remaining
- Cooldown remaining
- Current acceleration
- Distance traveled during current boost
- Expected straight-line boost distance
- Current environment type
- Current special state
- Controller detected
- Last input source
- Current tracking state
- Successful hide triggered
- Cooldown reduction applied

Debug visualization must include:

- Collision shapes
- Tag radius
- Wall detection range
- Rebound direction arc
- Hazard bounds
- Tunnel routes
- Breakable obstacle classification

---

## 11. Data Architecture

Each archetype should use a shared character profile resource.

Suggested resource:

`CharacterProfile`

Possible fields:

- archetype_name
- base_speed
- boost_duration
- boost_top_speed
- boost_acceleration_time
- boost_cooldown
- boost_steering
- recovery_duration
- special_feature_type
- special_feature_values

Suggested resource files:

- `resources/characters/breaker.tres`
- `resources/characters/hurdler.tres`
- `resources/characters/hazardborn.tres`
- `resources/characters/tunneler.tres`
- `resources/characters/chase.tres`

Shared behavior should remain in shared scripts.

Do not create one movement script per character unless a special mechanic cannot reasonably be separated into a component.

---

## 12. Suggested Project Structure

```text
melee-mayhem/
├── project.godot
├── DESIGN_SPEC.md
├── README.md
├── scenes/
│   ├── main.tscn
│   ├── arena.tscn
│   ├── player.tscn
│   └── controller_test.tscn
├── scripts/
│   ├── player/
│   │   ├── player_controller.gd
│   │   ├── boost_controller.gd
│   │   └── player_state.gd
│   ├── gameplay/
│   │   ├── tag_system.gd
│   │   ├── round_manager.gd
│   │   └── tracking_system.gd
│   ├── world/
│   │   ├── solid_wall.gd
│   │   ├── low_barrier.gd
│   │   ├── breakable_obstacle.gd
│   │   ├── hazard_zone.gd
│   │   └── tunnel_route.gd
│   └── ui/
│       ├── debug_panel.gd
│       └── cooldown_display.gd
├── resources/
│   ├── character_profile.gd
│   └── characters/
│       ├── breaker.tres
│       ├── hurdler.tres
│       ├── hazardborn.tres
│       ├── tunneler.tres
│       └── chase.tres
└── tests/
    ├── boost_distance_test.gd
    ├── cooldown_test.gd
    └── character_profile_test.gd
    