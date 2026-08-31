# Savvy Tycoon v1.6 — economy model patch

This patch fixes the crop/plot-upgrade relationship.

## Rule
Crop data owns:
- seed cost
- sale price
- base growth days
- harvest window
- base yield

Plot upgrade owns:
- yield multiplier
- growth reduction in days

Effective values:
- final_yield = crop.base_yield * plot.yield_multiplier
- final_growth_days = max(1, crop.growth_days - plot.growth_reduction_days)

Current matrix:
- Carrot: L1 1/2d, L2 2/2d, L3 2/1d, L4 3/1d
- Potato: L1 2/3d, L2 4/3d, L3 4/2d, L4 6/2d

Replace:
- scripts/core/GameManager.gd
- scripts/farm/FarmPlot.gd
- scripts/ui/HUD.gd

No scene changes are required.

Important: this patch does not change prices or upgrade costs. Those should be balanced only after the 6-plot / 150-day simulation.
