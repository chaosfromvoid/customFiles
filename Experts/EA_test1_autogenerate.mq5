//+------------------------------------------------------------------+
//|                                        EA_test1_autogenerate.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalCustomMACD.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedRisk.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title            ="EA_test1_autogenerate"; // Document name
ulong                    Expert_MagicNumber      =10118;                   //
bool                     Expert_EveryTick        =false;                   //
//--- inputs for main signal
input int                Signal_ThresholdOpen    =100;                      // Signal threshold value to open [0...100]  defaut 10
input int                Signal_ThresholdClose   =100;                      // Signal threshold value to close [0...100] defaut 10
input double             Signal_PriceLevel       =0.0;                     // Price level to execute a deal
input double             Signal_StopLevel        =50.0;                    // Stop Loss level (in points)
input double             Signal_TakeLevel        =50.0;                    // Take Profit level (in points)
input int                Signal_Expiration       =4;                       // Expiration of pending orders (in bars)
input int                Signal_MA_PeriodMA      =200;                     // Moving Average(200,0,...) Period of averaging
input int                Signal_MA_Shift         =0;                       // Moving Average(200,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method        =MODE_EMA;                // Moving Average(200,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied       =PRICE_CLOSE;             // Moving Average(200,0,...) Prices series
input double             Signal_MA_Weight        =1.0;                     // Moving Average(200,0,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast  =12;                      // MACD(12,26,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow  =26;                      // MACD(12,26,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal=9;                       // MACD(12,26,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied     =PRICE_CLOSE;             // MACD(12,26,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight      =1.0;                     // MACD(12,26,9,PRICE_CLOSE) Weight [0...1.0]
//--- inputs for money
input double             Money_FixRisk_Percent   =2.0;                     // Risk percentage
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);    // set m_threshold_open
   signal.ThresholdClose(Signal_ThresholdClose);  // set m_threshold_close
   signal.PriceLevel(Signal_PriceLevel);          // set m_price_level
   signal.StopLevel(Signal_StopLevel);            // set m_stop_level
   signal.TakeLevel(Signal_TakeLevel);            // set m_take_level
   signal.Expiration(Signal_Expiration);          // set m_expiration
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_MA_PeriodMA);
   filter0.Shift(Signal_MA_Shift);
   filter0.Method(Signal_MA_Method);
   filter0.Applied(Signal_MA_Applied);
   filter0.Weight(Signal_MA_Weight);
//---Custom: On garde juste le pattern0, soit le prix doit etre du bon coté
   filter0.Pattern_0(100);
   filter0.Pattern_1(0);
   filter0.Pattern_2(0);
   filter0.Pattern_3(0);
//--- Creating filter CSignalMACD
   CSignalCustomMACD *filter1=new CSignalCustomMACD;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodFast(Signal_MACD_PeriodFast);
   filter1.PeriodSlow(Signal_MACD_PeriodSlow);
   filter1.PeriodSignal(Signal_MACD_PeriodSignal);
   filter1.Applied(Signal_MACD_Applied);
   filter1.Weight(Signal_MACD_Weight);
//---Custom: On garde juste le pattern2, soit le crossover des deux signaux (du bon cote bien sur)
   filter1.Pattern_0(0);
   filter1.Pattern_1(0);
   filter1.Pattern_2(100);
   filter1.Pattern_3(0);
   filter1.Pattern_4(0);
   filter1.Pattern_5(0);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedRisk *money=new CMoneyFixedRisk;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixRisk_Percent);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
