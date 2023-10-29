### demo account

```jsx
Login:	61136943
Password:	g2beoavC / jakarta08
Server:	mt5-demo01.pepperstone.com
Leverage:	1:200
Currency:	USD
```

## Indicator Tutorial

### Components

An MT5 indicator is comprised of sections / parts:

- property
- globals
- inputs
- init
- deinit
- main

### #1 Property

a buffler and a plot

```cpp
#property indicator_buffers 1
#property indicator_plots 1
```

visual property

```cpp
#property indicator_type1 DRAW_LINE 
#property indicator_label1 "SlowMA"
#property indicator_color1 clrGray 
#property indicator_style1 STYLE_SOLID 
#property indicator_width1 4
```

### #2 Inputs

comments → translated as input labels

```cpp
input int InpSlowMAPeriod = 34; // Slow Period
input ENUM_MA_METHOD InpSlowMAMode = MODE_EMA; // Slow MA Mode

input int InpFastMAPeriod = 13; // Fast Period
input ENUM_MA_METHOD InpFastMAMode = MODE_EMA; // Fast MA Mode

input int InpSignalMAPeriod = 5; // Signal Period
input ENUM_MA_METHOD InpSignalMAMode = MODE_EMA; // MA Mode
```

### #4 Globals

Global variables meant to hold persistent value / values 

does not get reset every tick

```cpp
double BufferFast[];
double BufferSlow[];
double BufferSignal[];

int FastHandle;
int SlowHandle;
int SignalHandle;

int MaxPeriod;
```

### #5 Init

connect buffer → array

this buffer / array values will be accessible via → data window

```cpp
SetIndexBuffer(0, BufferSlow, INDICATOR_DATA);
```

retrieve the earliest available bar

```cpp
MaxPeriod = (int) MathMax(MathMax(InpSignalMAPeriod, InpFastMAPeriod), InpSlowMAPeriod);
```

set the first bar → visual plot is set

```cpp
PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MaxPeriod);
```

retrieve indicator (MA) handles

```cpp
SlowHandle = iMA(Symbol(), Period(), InpSlowMAPeriod, 0, InpSlowMAMode, PRICE_CLOSE);
FastHandle = iMA(Symbol(), Period(), InpFastMAPeriod, 0, InpFastMAMode, PRICE_CLOSE);
SignalHandle = iMA(Symbol(), Period(), InpSignalMAPeriod, 0, InpSignalMAMode, PRICE_CLOSE);
```

### #6 Main

respect stop flag → avoid loop

skip if stopped

```cpp
if (IsStopped()) return(0);
```

skip if bars loaded is not enough

```cpp
if (rates_total<MaxPeriod) return(0);

if (BarsCalculated(SlowHandle)<rates_total) return(0);
if (BarsCalculated(FastHandle)<rates_total) return(0);
if (BarsCalculated(SignalHandle)<rates_total) return(0);
```

efficient loading

```cpp
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
```

copy to buffer

```cpp
if (CopyBuffer(SlowHandle, 0, 0, copyBars, BufferSlow)<=0) return(0);
```

onCalculate()

```cpp
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
```

The selected code is the beginning of a function called OnCalculate() in the MA Ribbon.mq5 file. This function is used to calculate the moving averages for a trading strategy.

The function takes in several parameters, including the number of bars in the chart (rates_total), the number of bars that have already been calculated (prev_calculated), and arrays of data for the open, high, low, and close prices of each bar. Additionally, the function takes in arrays for the tick volume, volume, and spread of each bar, as well as an array of datetime values for the time of each bar.

The purpose of this function is to calculate the moving averages for the trading strategy. The specific calculations are not shown in the selected code, but they likely involve using the data arrays to calculate the moving averages using a specific formula or function.

Overall, the OnCalculate() function is an important part of the MA Ribbon.mq5 file, as it is used to calculate the moving averages for the trading strategy. The function takes in several parameters that provide the necessary data for the calculations, and likely uses a specific formula or function to calculate the moving averages.

### #7 Deinit

```cpp
if (SlowHandle!=INVALID_HANDLE) IndicatorRelease(SlowHandle);
if (FastHandle!=INVALID_HANDLE) IndicatorRelease(FastHandle);
if (SignalHandle!=INVALID_HANDLE) IndicatorRelease(SignalHandle);
```