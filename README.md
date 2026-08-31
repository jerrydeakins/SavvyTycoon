# Savvy Tycoon — Prototype v1.0

Fixes from v0.3:
- explicit Godot 4.7 project feature declaration;
- four StaticBody2D boundary walls around the farm;
- Camera2D limits match the 1280x720 farm;
- player can no longer walk outside the playable area.

The prototype remains intentionally single-scene to eliminate PackedScene dependency issues.

Next gameplay step: plot interaction with E, then planting/watering/harvesting.


## v0.5 change
Farm plots are now StaticBody2D obstacles, so the CharacterBody2D player cannot walk through them.
The plot collision rectangle exactly matches the 84x56 placeholder plot.

Next: add a separate interaction sensor so the player can approach a plot and press E without making the plot itself non-solid.


## v0.6 change
- Added a dedicated interaction sensor around the player.
- E interacts with the nearest reachable farm plot.
- Empty plot: plant carrot for $5.
- Planted plot: water it.
- Growing plot: shows that the crop is growing.
- Ready plot: harvests one carrot into storage.
- HUD shows contextual E prompt and temporary action messages.

For this prototype, growth is intentionally not time-based yet; the next step is the game-day/growth cycle.


## v0.7 fix
The previous interaction system relied on Area2D body-enter/exit signals. For the first prototype this was unnecessarily fragile.
v0.7 uses a simpler and deterministic approach:
- every plot belongs to the `farm_plots` group;
- the player finds the nearest plot by distance every physics frame;
- E acts on that plot when it is within 72 px;
- the prompt is driven by the same `current_plot` value.

The plots remain StaticBody2D obstacles.


## v0.8 change
- Added manual "Следующий день" button for prototype testing.
- TimeManager advances the game day.
- Watered crops advance growth once per day.
- Carrot requires 2 watered growth days to become READY.
- Water is consumed by the growth tick, so the crop must be watered again before the next growth day.
- HUD shows growth progress for the nearby plot.

Test:
Day 1: plant + water
Next day -> 1/2
Water
Next day -> READY (2/2)
E -> harvest


## v0.9 fix
- Fixed the growth loop: a crop in GROWING state can now be watered again.
- HUD now shows `E Полить грядку` for an unwatered growing crop.
- A watered plot stays visually darker and displays small water marks until the next day.
- A watered growth day increments growth and consumes the watering state.

Expected test: plant -> water -> next day (1/2) -> water again -> next day (2/2 / READY) -> harvest.


## v1.0 change
- Added a physical prototype sales point on the farm.
- Harvested carrots are stored as inventory units.
- E at the sales point sells all carrots currently in storage and adds revenue to money.
- HUD shows the current sales action and price.
- Sale price is temporarily fixed at $8/unit for prototype testing; final economy values remain subject to balance.

Test:
Harvest carrot(s) -> walk to the sales point -> E -> storage decreases to 0 and money increases.


## v1.2 cash-flow safety
- Reaching $0 is not an automatic game over. Existing planted crops can still be grown, harvested and sold.
- Added a one-time `Аварийная помощь +$10` button, available only while money is exactly $0.
- The emergency grant is consumed permanently after use.
- The normal economy is unchanged: seeds and upgrades still require actual money.

Test:
1. Spend all money until HUD shows `Деньги: 0`.
2. If a crop is already planted, use `Следующий день` and continue its growth normally.
3. If needed, click `Аварийная помощь +$10`; money becomes $10 and the button disappears permanently.
4. Spend the emergency money and verify it cannot be claimed again.


## v1.3 second crop
- Added potatoes: seeds $15, yield 2, sale price $10/unit, growth 3 watered days.
- Use the crop buttons in the upper-left corner to select carrots or potatoes before planting.
- Storage tracks each crop separately; selling at the market sells the entire mixed inventory.
- Potato has a larger payout but ties up more capital, takes longer to grow, and uses more storage per harvest.


## v1.4 starter mentor
- Els van der Berg now stands beside the farm and is the first interactive NPC.
- Approach her and press `E` for a two-page introduction to the farming loop; use `Продолжить` or `Закрыть` to control the dialogue.
- Els has a physical collision body, so the player cannot pass through her.
- The NPC uses a temporary drawn silhouette; the character references in `Reference/` define the final art direction.


## v1.5 time and harvest expiry
- The clock now advances automatically from 06:00 to 18:00; one workday lasts about 27 real-time minutes.
- At 18:00, the game advances to the next day and applies growth and crop-expiry rules.
- Dialogues pause the clock. `DEBUG: Следующий день` remains available while debug controls are enabled.
- A ready carrot remains harvestable for two following days; potatoes remain harvestable for four. After that, the crop spoils and must be cleared with `E`.
