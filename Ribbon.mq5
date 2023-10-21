//+------------------------------------------------------------------+
//|                                                    MA Ribbon.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots 1

#property indicator_type1 DRAW_LINE 
#property indicator_label1 "SlowMA"
#property indicator_color1 clrGray 
#property indicator_style1 STYLE_SOLID 
#property indicator_width1 4

//--- input parameters
input int InpSlowMAPeriod = 34; // Slow Period
input ENUM_MA_METHOD InpSlowMAMode = MODE_EMA; // Slow MA Mode

input int InpFastMAPeriod = 13; // Fast Period
input ENUM_MA_METHOD InpFastMAMode = MODE_EMA; // Fast MA Mode

input int InpSignalMAPeriod = 5; // Signal Period
input ENUM_MA_METHOD InpSignalMAMode = MODE_EMA; // MA Mode

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
   SetIndexBuffer(0, BufferSlow, INDICATOR_DATA);
   
   MaxPeriod = (int) MathMax(MathMax(InpSignalMAPeriod, InpFastMAPeriod), InpSlowMAPeriod);
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MaxPeriod);

   SlowHandle = iMA(Symbol(), Period(), InpSlowMAPeriod, 0, InpSlowMAMode, PRICE_CLOSE);
   FastHandle = iMA(Symbol(), Period(), InpFastMAPeriod, 0, InpFastMAMode, PRICE_CLOSE);
   SignalHandle = iMA(Symbol(), Period(), InpSignalMAPeriod, 0, InpSignalMAMode, PRICE_CLOSE);
   
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
   if (prev_calculated>rates_total || prev_calculated<=0) {
      // first run through the loop
      copyBars = rates_total;
   } else {
      // if new bar has appeared, rates_total will be 1 greater than prev_calculated
      copyBars = rates_total-prev_calculated;
      if (prev_calculated>0) copyBars++;
   }
   
   // copy the bars
   if (CopyBuffer(SlowHandle, 0, 0, copyBars, BufferSlow)<=0) return(0);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
