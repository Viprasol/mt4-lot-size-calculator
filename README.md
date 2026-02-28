# 📊 MT4 Lot Size Calculator Indicator

A free, open-source **MetaTrader 4 (MT4) lot size calculator** indicator that calculates the correct position size based on your account balance, risk percentage, and stop loss in pips — displayed live on your chart.

> Built and maintained by [Viprasol Tech](https://viprasol.com) — custom MT4/MT5 EA development and algorithmic trading solutions.

---

## ✨ Features

- ✅ **Risk-based position sizing** — never risk more than you define
- ✅ **Live on-chart panel** — updates on every tick
- ✅ **5-digit broker support** — auto-detects pip size for all brokers
- ✅ **Works on all pairs** — Forex, indices, commodities, crypto CFDs
- ✅ **Balance or Equity mode** — choose your account size base
- ✅ **Lot normalisation** — respects broker's min/max/step constraints
- ✅ **Color alerts** — green (safe), orange (at min lot), red (at max lot)
- ✅ **Configurable panel position** — any corner of the chart
- ✅ Zero repaint, zero DLL, zero external dependencies

---

## 📸 Panel Preview

```
⬛ LOT SIZE CALCULATOR
────────────────────────
Balance:    USD 10000.00
Risk:       1.0%  (USD 100.00)
Stop Loss:  20.0 pips
────────────────────────
► Lot Size:  0.50 lots       ← green = safe
Risk ($):   USD 100.00 at risk
```

---

## 🚀 Installation

1. Download `LotSizeCalculator.mq4`
2. Open MT4 → **File → Open Data Folder**
3. Navigate to `MQL4/Indicators/`
4. Copy `LotSizeCalculator.mq4` into that folder
5. Restart MT4 (or right-click **Indicators** in Navigator → **Refresh**)
6. Drag **LotSizeCalculator** onto any chart

---

## ⚙️ Input Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `RiskPercent` | `1.0` | % of account to risk per trade |
| `StopLossPips` | `20.0` | Your planned stop loss in pips |
| `UseEquity` | `false` | Use Equity instead of Balance |
| `TextColor` | `White` | Panel text color |
| `FontSize` | `12` | Panel font size |
| `Corner` | `Top-Left` | Panel position on chart |
| `CornerX` | `10` | X offset in pixels |
| `CornerY` | `20` | Y offset in pixels |

---

## 📐 How the Calculation Works

```
Risk Amount  = Account Balance × (Risk% / 100)
Pip Value    = Tick Value × (Point / Tick Size) × Pip Multiplier
Lot Size     = Risk Amount / (Stop Loss Pips × Pip Value)
```

The result is normalised to your broker's `LOTSTEP` and clamped between `MINLOT` and `MAXLOT`.

---

## 💡 Usage Tips

- Set `StopLossPips` to match where you plan to place your stop loss **before** entering a trade
- Use `RiskPercent = 1.0` for conservative risk, `2.0` for moderate
- Orange lot size = position floored to minimum lot (reduce SL or add capital)
- Red lot size = position capped at maximum lot (check broker restrictions)
- Works correctly on JPY pairs and 5-digit brokers automatically

---

## 🤝 Need a Custom MT4/MT5 EA?

This indicator is a free tool from [Viprasol Tech](https://viprasol.com).

We build **custom Expert Advisors** for:
- Algorithmic trading strategies
- Risk management systems
- Trade copiers and multi-account managers
- MT4/MT5 migration and optimisation

👉 **[Get a custom EA built →](https://viprasol.com/services/trading-software)**

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

## 🏷️ Topics

`mt4` `metatrader4` `expert-advisor` `forex` `lot-size-calculator` `position-sizing` `risk-management` `trading` `mql4` `algorithmic-trading`
