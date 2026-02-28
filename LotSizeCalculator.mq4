//+------------------------------------------------------------------+
//|                                          LotSizeCalculator.mq4  |
//|                                Copyright 2026, Viprasol Tech     |
//|                                        https://viprasol.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Viprasol Tech"
#property link      "https://viprasol.com"
#property version   "1.00"
#property description "Lot Size Calculator — Risk-based position sizing for MT4"
#property strict
#property indicator_chart_window

//--- Input Parameters
input double RiskPercent      = 1.0;    // Risk % of account balance
input double StopLossPips     = 20.0;   // Stop Loss in pips
input bool   UseEquity        = false;  // Use Equity instead of Balance
input color  TextColor        = clrWhite;
input int    FontSize         = 12;
input int    CornerX          = 10;     // X offset from corner
input int    CornerY          = 20;     // Y offset from corner
input ENUM_BASE_CORNER Corner = CORNER_LEFT_UPPER; // Panel corner

//--- Label names
#define LBL_TITLE   "LSC_Title"
#define LBL_BALANCE "LSC_Balance"
#define LBL_RISK    "LSC_Risk"
#define LBL_SL      "LSC_SL"
#define LBL_LOT     "LSC_Lot"
#define LBL_DOLLAR  "LSC_Dollar"
#define LBL_DIV1    "LSC_Div1"
#define LBL_DIV2    "LSC_Div2"

//+------------------------------------------------------------------+
//| Create a text label on the chart                                 |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr, int size = 10, string font = "Arial Bold")
{
   if (ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER,    Corner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  size);
   ObjectSetString (0, name, OBJPROP_FONT,      font);
   ObjectSetString (0, name, OBJPROP_TEXT,      text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   CreateLabel(LBL_TITLE,   "⬛ LOT SIZE CALCULATOR",        CornerX, CornerY,       clrDodgerBlue, FontSize + 2);
   CreateLabel(LBL_DIV1,    "────────────────────────",      CornerX, CornerY + 25,  C'80,80,80',   FontSize - 2, "Arial");
   CreateLabel(LBL_BALANCE, "Balance:   Loading...",         CornerX, CornerY + 45,  TextColor,     FontSize, "Arial");
   CreateLabel(LBL_RISK,    "Risk:      Loading...",         CornerX, CornerY + 65,  TextColor,     FontSize, "Arial");
   CreateLabel(LBL_SL,      "Stop Loss: Loading...",         CornerX, CornerY + 85,  TextColor,     FontSize, "Arial");
   CreateLabel(LBL_DIV2,    "────────────────────────",      CornerX, CornerY + 105, C'80,80,80',   FontSize - 2, "Arial");
   CreateLabel(LBL_LOT,     "Lot Size:  Loading...",         CornerX, CornerY + 120, clrLimeGreen,  FontSize + 1, "Arial Bold");
   CreateLabel(LBL_DOLLAR,  "Risk ($):  Loading...",         CornerX, CornerY + 145, clrGold,       FontSize, "Arial");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Calculate pip value in account currency                          |
//+------------------------------------------------------------------+
double GetPipValue()
{
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);
   double point     = MarketInfo(Symbol(), MODE_POINT);

   // Detect 5-digit brokers (pip = 10 points)
   double pipMultiplier = 1.0;
   if (StringFind(Symbol(), "JPY") < 0 && point < 0.009)
      pipMultiplier = 10.0;
   else if (StringFind(Symbol(), "JPY") >= 0 && point < 0.09)
      pipMultiplier = 10.0;

   double pipValue = tickValue * (point / tickSize) * pipMultiplier;
   return pipValue;
}

//+------------------------------------------------------------------+
//| Calculate recommended lot size                                   |
//+------------------------------------------------------------------+
double CalculateLotSize(double accountSize, double riskPct, double slPips)
{
   if (slPips <= 0) return 0;

   double riskAmount  = accountSize * (riskPct / 100.0);
   double pipValue    = GetPipValue();

   if (pipValue <= 0) return 0;

   double rawLot      = riskAmount / (slPips * pipValue);

   // Normalise to broker's lot constraints
   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

   double normLot = MathFloor(rawLot / lotStep) * lotStep;
   normLot = MathMax(minLot, MathMin(maxLot, normLot));

   return NormalizeDouble(normLot, 2);
}

//+------------------------------------------------------------------+
//| Main calculation — runs on every tick                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   double accountSize = UseEquity ? AccountEquity() : AccountBalance();
   double lotSize     = CalculateLotSize(accountSize, RiskPercent, StopLossPips);
   double riskAmount  = accountSize * (RiskPercent / 100.0);
   string currency    = AccountCurrency();

   // Format lot size color (warn if hitting min/max)
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   color  lotClr = clrLimeGreen;
   if (lotSize <= minLot) lotClr = clrOrange;
   if (lotSize >= maxLot) lotClr = clrRed;

   // Update labels
   string balLabel = UseEquity ? "Equity:" : "Balance:";
   ObjectSetString(0, LBL_BALANCE, OBJPROP_TEXT,
      StringFormat("%-11s %s %.2f", balLabel, currency, accountSize));

   ObjectSetString(0, LBL_RISK, OBJPROP_TEXT,
      StringFormat("%-11s %.1f%%  (%s %.2f)", "Risk:", RiskPercent, currency, riskAmount));

   ObjectSetString(0, LBL_SL, OBJPROP_TEXT,
      StringFormat("%-11s %.1f pips", "Stop Loss:", StopLossPips));

   ObjectSetString(0, LBL_LOT, OBJPROP_TEXT,
      StringFormat("%-11s %.2f lots", "► Lot Size:", lotSize));

   ObjectSetString(0, LBL_DOLLAR, OBJPROP_TEXT,
      StringFormat("%-11s %s %.2f at risk", "Risk ($):", currency, riskAmount));

   ObjectSetInteger(0, LBL_LOT, OBJPROP_COLOR, lotClr);

   ChartRedraw(0);
   return rates_total;
}

//+------------------------------------------------------------------+
//| Cleanup on removal                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   string labels[] = {LBL_TITLE, LBL_BALANCE, LBL_RISK, LBL_SL,
                      LBL_LOT, LBL_DOLLAR, LBL_DIV1, LBL_DIV2};
   for (int i = 0; i < ArraySize(labels); i++)
      ObjectDelete(0, labels[i]);
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
