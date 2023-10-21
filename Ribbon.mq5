//+------------------------------------------------------------------+
//|                                                    MA Ribbon.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots 3

#property indicator_type1 DRAW_FILLING
#property indicator_label1 "Channel FastMA;Channel SloweMA"
#property indicator_color1 clrYellow, clrFireBrick

#property indicator_type2 DRAW_LINE 
#property indicator_label2 "SlowMA"
#property indicator_color2 clrGray 
#property indicator_style2 STYLE_SOLID 
#property indicator_width2 4

#property indicator_type3 DRAW_LINE 
#property indicator_label3 "FastMA"
#property indicator_color3 clrBlue 
#property indicator_style3 STYLE_SOLID 
#property indicator_width3 3

//--- input parameters
input int InpSlowMAPeriod = 34; // Slow Period
input ENUM_MA_METHOD InpSlowMAMode = MODE_EMA; // Slow MA Mode

input int InpFastMAPeriod = 13; // Fast Period
input ENUM_MA_METHOD InpFastMAMode = MODE_EMA; // Fast MA Mode

input int InpSignalMAPeriod = 5; // Signal Period
input ENUM_MA_METHOD InpSignalMAMode = MODE_EMA; // MA Mode

double BufferFastChannel[];
double BufferSlowChannel[];
double BufferFast[];
double BufferSlow[];
double BufferSignal[];

int FastHandle;
int SlowHandle;
int SignalHandle;

int MaxPeriod;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, BufferFastChannel, INDICATOR_DATA);
   SetIndexBuffer(1, BufferSlowChannel, INDICATOR_DATA);
   SetIndexBuffer(2, BufferSlow, INDICATOR_DATA);
   SetIndexBuffer(3, BufferFast, INDICATOR_DATA);

   SetIndexBuffer(4, BufferSignal, INDICATOR_DATA);
   
   MaxPeriod = (int) MathMax(MathMax(InpSignalMAPeriod, InpFastMAPeriod), InpSlowMAPeriod);

   SlowHandle = iMA(Symbol(), Period(), InpSlowMAPeriod, 0, InpSlowMAMode, PRICE_CLOSE);
   FastHandle = iMA(Symbol(), Period(), InpFastMAPeriod, 0, InpFastMAMode, PRICE_CLOSE);
   SignalHandle = iMA(Symbol(), Period(), InpSignalMAPeriod, 0, InpSignalMAMode, PRICE_CLOSE);
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MaxPeriod);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, MaxPeriod);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, MaxPeriod);
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason){
   if (SlowHandle!=INVALID_HANDLE) IndicatorRelease(SlowHandle);
   if (FastHandle!=INVALID_HANDLE) IndicatorRelease(FastHandle);
   if (SignalHandle!=INVALID_HANDLE) IndicatorRelease(SignalHandle);
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
//---
   if (IsStopped()) return(0);
   
   if (rates_total<MaxPeriod) return(0);

   // check that the moving averages have all been calculated
   if (BarsCalculated(SlowHandle)<rates_total) return(0);
   if (BarsCalculated(FastHandle)<rates_total) return(0);
   if (BarsCalculated(SignalHandle)<rates_total) return(0);
   
   // copy just the bars that need to be copied
   int copyBars = 0;
   int startBar = 0;

   if (prev_calculated>rates_total || prev_calculated<=0) {
      // first run through the loop
      copyBars = rates_total;
      startBar = MaxPeriod;
   } else {
      // if new bar has appeared, rates_total will be 1 greater than prev_calculated
      copyBars = rates_total-prev_calculated;
      if (prev_calculated>0) copyBars++;
      startBar = prev_calculated-1;
   }
   
   // copy the bars
   if (CopyBuffer(SlowHandle, 0, 0, copyBars, BufferFastChannel)<=0) return(0);
   if (CopyBuffer(FastHandle, 0, 0, copyBars, BufferSlowChannel)<=0) return(0);
   if (CopyBuffer(SlowHandle, 0, 0, copyBars, BufferSlow)<=0) return(0);
   if (CopyBuffer(FastHandle, 0, 0, copyBars, BufferFast)<=0) return(0);
   if (CopyBuffer(SignalHandle, 0, 0, copyBars, BufferSignal)<=0) return(0);

   if (IsStopped()) return(0); // pre-loop exit check
   for (int i=startBar; i<rates_total && !IsStopped(); i++) {
      if ( (BufferFast[i]>=BufferSlow[i] && BufferSignal[i]<BufferFast[i]) 
      || (BufferFast[i]<BufferSlow[i] && BufferSignal[i]>BufferFast[i])) {
         BufferFast[i] = EMPTY_VALUE;
         BufferSlow[i] = EMPTY_VALUE;
         BufferFastChannel[i] = EMPTY_VALUE;
         BufferSlowChannel[i] = EMPTY_VALUE;
      }
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
