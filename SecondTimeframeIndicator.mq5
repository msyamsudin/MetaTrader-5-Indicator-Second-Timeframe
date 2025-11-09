//+------------------------------------------------------------------+
//|                                      SecondTimeframeIndicator.mq5 |
//|                          Candle detik dengan countdown timer      |
//+------------------------------------------------------------------+
#property copyright "Second TF Indicator"
#property link      ""
#property version   "1.04"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrDodgerBlue
#property indicator_label1  "Second TF"

//--- input parameters
input int InpSecondPeriod = 5;           // Periode dalam detik (1-59)
input color InpCandleColor = clrDodgerBlue; // Warna candle
input int InpCandleWidth = 1;            // Lebar candle
input int InpMaxBars = 200;              // Maksimal bars untuk ditampilkan
input bool InpShowInfo = true;           // Tampilkan info lengkap
input color InpCountdownColor = clrAqua; // Warna countdown timer
input int InpFontSize = 10;              // Ukuran font info

//--- structure untuk menyimpan data candle
struct CandleData
{
   datetime time;
   double open;
   double high;
   double low;
   double close;
   long tick_volume;
};

//--- indicator buffers
double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];

//--- global variables
CandleData candles[];
int candleCount = 0;
datetime currentCandleTime = 0;
double currentOpen = 0;
double currentHigh = 0;
double currentLow = 0;
double currentClose = 0;
long currentTickVolume = 0;
bool candleStarted = false;
int windowNumber = -1;
datetime lastUpdateTime = 0;
int lastSecondsRemaining = -1;

//--- object names
const string labelName = "SecondTF_Info";
const string countdownLabel = "SecondTF_Countdown";
const string countdownBox = "SecondTF_CountdownBox";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- check parameters
   if(InpSecondPeriod < 1 || InpSecondPeriod > 59)
   {
      Print("Error: Periode detik harus antara 1-59");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   //--- set indicator buffers
   SetIndexBuffer(0, OpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, LowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);
   
   //--- set as series for natural indexing (newest = 0)
   ArraySetAsSeries(OpenBuffer, true);
   ArraySetAsSeries(HighBuffer, true);
   ArraySetAsSeries(LowBuffer, true);
   ArraySetAsSeries(CloseBuffer, true);
   
   //--- set indicator properties
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Second TF [" + IntegerToString(InpSecondPeriod) + "s]");
   
   //--- set single color for all candles
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpCandleColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpCandleWidth);
   
   //--- set empty value to 0
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   
   //--- resize candle storage array
   if(!ArrayResize(candles, InpMaxBars))
   {
      Print("Error: Gagal resize array");
      return(INIT_FAILED);
   }
   
   //--- find window number
   windowNumber = ChartWindowFind();
   if(windowNumber < 0)
   {
      Print("Error: Window tidak ditemukan");
      return(INIT_FAILED);
   }
   
   //--- create labels for info display
   if(InpShowInfo)
      CreateInfoLabel();
   
   //--- set timer for smooth updates
   EventSetMillisecondTimer(100);
   
   Print("Indikator Second Timeframe dimulai: ", InpSecondPeriod, "s di window ", windowNumber);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   
   //--- delete all objects
   ObjectDelete(0, labelName);
   ObjectDelete(0, countdownLabel);
   ObjectDelete(0, countdownBox);
   
   Comment("");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create info label on chart                                       |
//+------------------------------------------------------------------+
void CreateInfoLabel()
{
   //--- create main info label
   if(!ObjectCreate(0, labelName, OBJ_LABEL, windowNumber, 0, 0))
      return;
      
   ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 25);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetString(0, labelName, OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, labelName, OBJPROP_BACK, false);
   
   //--- create countdown background box
   if(!ObjectCreate(0, countdownBox, OBJ_RECTANGLE_LABEL, windowNumber, 0, 0))
      return;
      
   ObjectSetInteger(0, countdownBox, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, countdownBox, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, countdownBox, OBJPROP_YDISTANCE, 5);
   ObjectSetInteger(0, countdownBox, OBJPROP_XSIZE, 80);
   ObjectSetInteger(0, countdownBox, OBJPROP_YSIZE, 40);
   ObjectSetInteger(0, countdownBox, OBJPROP_BGCOLOR, C'40,40,40');
   ObjectSetInteger(0, countdownBox, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, countdownBox, OBJPROP_COLOR, C'60,60,60');
   ObjectSetInteger(0, countdownBox, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, countdownBox, OBJPROP_BACK, false);
   ObjectSetInteger(0, countdownBox, OBJPROP_SELECTABLE, false);
   
   //--- create countdown label
   if(!ObjectCreate(0, countdownLabel, OBJ_LABEL, windowNumber, 0, 0))
      return;
      
   ObjectSetInteger(0, countdownLabel, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, countdownLabel, OBJPROP_XDISTANCE, 50);
   ObjectSetInteger(0, countdownLabel, OBJPROP_YDISTANCE, 18);
   ObjectSetInteger(0, countdownLabel, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, countdownLabel, OBJPROP_COLOR, InpCountdownColor);
   ObjectSetInteger(0, countdownLabel, OBJPROP_FONTSIZE, 14);
   ObjectSetString(0, countdownLabel, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, countdownLabel, OBJPROP_BACK, false);
   ObjectSetInteger(0, countdownLabel, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Normalize time to second period                                  |
//+------------------------------------------------------------------+
datetime NormalizeTime(datetime time)
{
   MqlDateTime dt;
   TimeToStruct(time, dt);
   dt.sec = (dt.sec / InpSecondPeriod) * InpSecondPeriod;
   return StructToTime(dt);
}

//+------------------------------------------------------------------+
//| Calculate seconds remaining until candle close                   |
//+------------------------------------------------------------------+
int GetSecondsRemaining(datetime currentTime)
{
   if(!candleStarted) 
      return InpSecondPeriod;
   
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   
   int currentSecond = dt.sec % 60;
   int candleStartSecond = (currentSecond / InpSecondPeriod) * InpSecondPeriod;
   int remaining = candleStartSecond + InpSecondPeriod - currentSecond;
   
   return (remaining <= 0) ? InpSecondPeriod : remaining;
}

//+------------------------------------------------------------------+
//| Update info labels - only when changed                          |
//+------------------------------------------------------------------+
void UpdateLabels(datetime currentTime)
{
   if(!InpShowInfo) 
      return;
   
   //--- calculate countdown
   int secondsLeft = GetSecondsRemaining(currentTime);
   
   //--- only update if changed
   if(secondsLeft == lastSecondsRemaining && currentTime == lastUpdateTime)
      return;
      
   lastSecondsRemaining = secondsLeft;
   lastUpdateTime = currentTime;
   
   //--- prepare main info text
   string info = StringFormat(
      "Period: %ds | Candles: %d\n" +
      "O: %." + IntegerToString(_Digits) + "f | H: %." + IntegerToString(_Digits) + "f\n" +
      "L: %." + IntegerToString(_Digits) + "f | C: %." + IntegerToString(_Digits) + "f\n" +
      "Ticks: %d | Range: %." + IntegerToString(_Digits) + "f",
      InpSecondPeriod, candleCount,
      currentOpen, currentHigh,
      currentLow, currentClose,
      currentTickVolume, (currentHigh - currentLow)
   );
   
   ObjectSetString(0, labelName, OBJPROP_TEXT, info);
   
   //--- prepare countdown text
   string countdownText = StringFormat("%02d", secondsLeft);
   
   //--- change color based on time remaining
   color boxColor;
   
   if(secondsLeft <= 2)
      boxColor = clrRed;
   else if(secondsLeft <= 5)
      boxColor = clrOrange;
   else
      boxColor = C'40,40,40';
   
   //--- update countdown
   ObjectSetInteger(0, countdownBox, OBJPROP_BGCOLOR, boxColor);
   ObjectSetString(0, countdownLabel, OBJPROP_TEXT, countdownText);
}

//+------------------------------------------------------------------+
//| Save current candle to history                                   |
//+------------------------------------------------------------------+
void SaveCurrentCandle()
{
   if(candleCount >= InpMaxBars)
   {
      //--- shift array
      for(int i = 0; i < InpMaxBars - 1; i++)
         candles[i] = candles[i + 1];
      candleCount = InpMaxBars - 1;
   }
   
   //--- save candle data
   candles[candleCount].time = currentCandleTime;
   candles[candleCount].open = currentOpen;
   candles[candleCount].high = currentHigh;
   candles[candleCount].low = currentLow;
   candles[candleCount].close = currentClose;
   candles[candleCount].tick_volume = currentTickVolume;
   candleCount++;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   //--- get current tick
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return(prev_calculated);
   
   //--- use bid price for tracking
   double price = (tick.last > 0) ? tick.last : tick.bid;
   datetime currentTime = (datetime)(tick.time_msc / 1000);
   datetime normalizedTime = NormalizeTime(currentTime);
   
   //--- check if new candle should start
   if(normalizedTime != currentCandleTime || !candleStarted)
   {
      //--- save previous candle
      if(candleStarted)
         SaveCurrentCandle();
      
      //--- start new candle
      currentCandleTime = normalizedTime;
      currentOpen = price;
      currentHigh = price;
      currentLow = price;
      currentClose = price;
      currentTickVolume = 1;
      candleStarted = true;
   }
   else
   {
      //--- update current candle
      if(price > currentHigh) 
         currentHigh = price;
      if(price < currentLow) 
         currentLow = price;
         
      currentClose = price;
      currentTickVolume++;
   }
   
   //--- calculate total bars including current
   int totalBars = candleCount + 1;
   
   //--- fill completed candles in reverse order (newest first)
   for(int i = 0; i < candleCount; i++)
   {
      OpenBuffer[candleCount - i] = candles[i].open;
      HighBuffer[candleCount - i] = candles[i].high;
      LowBuffer[candleCount - i] = candles[i].low;
      CloseBuffer[candleCount - i] = candles[i].close;
   }
   
   //--- always update current forming candle at index 0
   OpenBuffer[0] = currentOpen;
   HighBuffer[0] = currentHigh;
   LowBuffer[0] = currentLow;
   CloseBuffer[0] = currentClose;
   
   //--- update labels
   if(InpShowInfo)
      UpdateLabels(currentTime);
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function - for smooth countdown                            |
//+------------------------------------------------------------------+
void OnTimer()
{
   //--- update countdown
   if(InpShowInfo)
   {
      MqlTick tick;
      if(SymbolInfoTick(_Symbol, tick))
      {
         datetime currentTime = (datetime)(tick.time_msc / 1000);
         UpdateLabels(currentTime);
      }
   }
   
   ChartRedraw();
}
//+------------------------------------------------------------------+
