//+------------------------------------------------------------------+
//|                                       FX_GO_WAIT_Checker.mq5     |
//|                                              FX Entry GO / WAIT  |
//|                                                  Starter Kit     |
//+------------------------------------------------------------------+
//
//  Manual entry-checklist panel indicator for MetaTrader 5.
//
//  This indicator does NOT execute trades, NOT send orders, and does
//  NOT auto-detect chart conditions. It is a visual checklist panel
//  that lets the trader toggle 7 conditions via input parameters and
//  shows a live SCORE + GO / CAUTION / WAIT decision on the chart.
//
//  DISCLAIMER:
//    This is NOT investment advice. The score and decision are
//    derived purely from the user's own input flags. Final trading
//    decisions are entirely the responsibility of the user.
//
//  Usage:
//    1) Place this file in:  <MT5 data folder>/MQL5/Indicators/
//    2) Open MetaEditor (F4 in MT5), open the file, press F7 to compile.
//    3) In MT5: Navigator -> Indicators -> Custom -> drag onto chart.
//    4) Set the seven Cond inputs (true/false) per current setup.
//    5) Re-attach the indicator (or change a parameter) to refresh.
//
//+------------------------------------------------------------------+

#property copyright "FX GO/WAIT Starter Kit"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//--- Inputs: the seven entry conditions ---------------------------------
input bool   Cond1_TrendMatch    = false;  // 1: 上位足トレンドが一致している
input bool   Cond2_Pullback      = false;  // 2: 押し目 / 戻り目が成立している
input bool   Cond3_Breakout      = false;  // 3: ブレイク確認がある
input bool   Cond4_Volatility    = false;  // 4: ボラティリティが十分
input bool   Cond5_RR            = false;  // 5: RR 1:1.5以上が見込める
input bool   Cond6_StopClear     = false;  // 6: 損切り位置が明確
input bool   Cond7_TimeOK        = false;  // 7: 時間帯が悪くない

//--- Inputs: panel layout & colors --------------------------------------
input int    PanelX              = 12;     // Panel left offset (px)
input int    PanelY              = 12;     // Panel top offset (px)
input color  ColorBG             = C'10,16,30';
input color  ColorBorder         = C'70,100,150';
input color  ColorTitle          = C'231,236,247';
input color  ColorOK             = C'95,231,168';
input color  ColorNG             = C'141,154,184';
input color  ColorScore          = C'231,236,247';
input color  ColorGO             = C'95,231,168';
input color  ColorCAUTION        = C'255,200,87';
input color  ColorWAIT           = C'255,107,107';
input color  ColorAccent         = C'94,179,255';

//--- Constants ----------------------------------------------------------
const string OBJ_PREFIX = "FX_GW_";
const string LABELS[7] = {
   "1. Trend match (HTF)",
   "2. Pullback formed",
   "3. Breakout confirmed",
   "4. Volatility OK",
   "5. RR >= 1:1.5",
   "6. Stop loss clear",
   "7. Time of day OK"
};

//+------------------------------------------------------------------+
//| Helper: delete every object created by this indicator            |
//+------------------------------------------------------------------+
void DeleteAllOurObjects()
  {
   int n = ObjectsTotal(0);
   for(int i = n - 1; i >= 0; i--)
     {
      string nm = ObjectName(0, i);
      if(StringFind(nm, OBJ_PREFIX) == 0)
         ObjectDelete(0, nm);
     }
  }

//+------------------------------------------------------------------+
//| Helper: draw a text label                                        |
//+------------------------------------------------------------------+
void DrawLabel(const string name, int x, int y, const string text,
               color clr, int fontSize)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString (0, name, OBJPROP_TEXT,       text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   fontSize);
   ObjectSetString (0, name, OBJPROP_FONT,       "Consolas");
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//| Helper: draw a filled rectangle background                       |
//+------------------------------------------------------------------+
void DrawRect(const string name, int x, int y, int w, int h,
              color bg, color border)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     border);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//| Compute score + decision from current input flags                |
//+------------------------------------------------------------------+
int ComputeScore()
  {
   bool conds[7];
   conds[0] = Cond1_TrendMatch;
   conds[1] = Cond2_Pullback;
   conds[2] = Cond3_Breakout;
   conds[3] = Cond4_Volatility;
   conds[4] = Cond5_RR;
   conds[5] = Cond6_StopClear;
   conds[6] = Cond7_TimeOK;
   int yes = 0;
   for(int i = 0; i < 7; i++) if(conds[i]) yes++;
   int score = yes * 15;
   if(score > 100) score = 100;
   return score;
  }

//+------------------------------------------------------------------+
//| Decision text + color from score                                 |
//+------------------------------------------------------------------+
string DecisionText(int score, color &outColor)
  {
   if(score >= 80){ outColor = ColorGO;      return "GO"; }
   if(score >= 60){ outColor = ColorCAUTION; return "CAUTION"; }
                    outColor = ColorWAIT;    return "WAIT";
  }

//+------------------------------------------------------------------+
//| Risk text from score + missing count                             |
//+------------------------------------------------------------------+
string RiskText(int score, int missing)
  {
   if(score >= 80) return (missing == 0) ? "LOW" : "MEDIUM";
   if(score >= 60) return "MEDIUM";
   return "HIGH";
  }

//+------------------------------------------------------------------+
//| Render full panel                                                |
//+------------------------------------------------------------------+
void RedrawPanel()
  {
   DeleteAllOurObjects();

   bool conds[7];
   conds[0] = Cond1_TrendMatch;
   conds[1] = Cond2_Pullback;
   conds[2] = Cond3_Breakout;
   conds[3] = Cond4_Volatility;
   conds[4] = Cond5_RR;
   conds[5] = Cond6_StopClear;
   conds[6] = Cond7_TimeOK;

   int x = PanelX, y = PanelY;
   int w = 290, h = 268;

   // Background card
   DrawRect(OBJ_PREFIX + "BG", x, y, w, h, ColorBG, ColorBorder);

   // Title bar
   DrawLabel(OBJ_PREFIX + "TITLE", x + 12, y + 8,
             "FX GO / WAIT CHECKER", ColorTitle, 11);
   DrawLabel(OBJ_PREFIX + "SUB", x + 12, y + 26,
             "7-condition entry pre-check", ColorAccent, 8);

   // Checklist rows
   int yes = 0;
   for(int i = 0; i < 7; i++)
     {
      string mark  = conds[i] ? "[YES]" : "[ -- ]";
      color  cText = conds[i] ? ColorOK : ColorNG;
      string line  = mark + "  " + LABELS[i];
      DrawLabel(OBJ_PREFIX + "L" + IntegerToString(i),
                x + 12, y + 46 + i * 20, line, cText, 9);
      if(conds[i]) yes++;
     }

   // Score
   int score   = (yes * 15 > 100) ? 100 : yes * 15;
   int missing = 7 - yes;

   color  decColor;
   string dec = DecisionText(score, decColor);
   string risk = RiskText(score, missing);

   int yScore = y + 46 + 7 * 20 + 4;
   DrawLabel(OBJ_PREFIX + "SCORE_L", x + 12, yScore,
             "SCORE", ColorAccent, 8);
   DrawLabel(OBJ_PREFIX + "SCORE_V", x + 70, yScore - 3,
             IntegerToString(score) + " / 100", ColorScore, 12);

   int yDec = yScore + 22;
   DrawLabel(OBJ_PREFIX + "DEC_L", x + 12, yDec,
             "DECISION", ColorAccent, 8);
   DrawLabel(OBJ_PREFIX + "DEC_V", x + 90, yDec - 3,
             dec, decColor, 13);

   int yRisk = yDec + 22;
   DrawLabel(OBJ_PREFIX + "RISK_L", x + 12, yRisk,
             "RISK", ColorAccent, 8);
   DrawLabel(OBJ_PREFIX + "RISK_V", x + 70, yRisk - 3,
             risk, decColor, 11);

   // Disclaimer
   DrawLabel(OBJ_PREFIX + "DISCL", x + 12, y + h - 18,
             "Not investment advice.", ColorNG, 7);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "FX_GO_WAIT_Checker");
   RedrawPanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllOurObjects();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//| Static panel; redraw only on first calc / parameter change.      |
//+------------------------------------------------------------------+
int OnCalculate(const int        rates_total,
                const int        prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[])
  {
   if(prev_calculated == 0)
      RedrawPanel();
   return(rates_total);
  }
//+------------------------------------------------------------------+
