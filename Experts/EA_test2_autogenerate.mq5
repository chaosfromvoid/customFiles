//+------------------------------------------------------------------+
//|                                        EA_test2_autogenerate.mq5 |
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
#include <Expert\CustomExpertFiles\SignalCustomMA1.mqh>
#include <Expert\CustomExpertFiles\SignalCustomMACD1.mqh>
#include <Expert\CustomExpertFiles\SignalCustomZigZag1.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedRisk.mqh>
//--- Fichier d'ecriture de fichier csv
#include <Files\FileArray2Csv.mqh>
#include <Files\FileSaveDatanalysis.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title            ="EA_test2_autogenerate"; // Document name
ulong                    Expert_MagicNumber      =10118;                   //
bool                     Expert_EveryTick        =false;                   //
//--- inputs for main signal
input int                Signal_ThresholdOpen    =100;                      // Signal threshold value to open [0...100]  defaut 10
input int                Signal_ThresholdClose   =100;                      // Signal threshold value to close [0...100] defaut 10
input double             Signal_PriceLevel       =0.0;                     // Price level to execute a deal
input double             Signal_StopLevel        =50.0;                    // Stop Loss level (in points)
input double             Signal_TakeLevel        =50.0;                    // Take Profit level (in points)
input int                Signal_Expiration       =4;                       // Expiration of pending orders (in bars)
input int                Signal_ZigZag_Depth     =12;
input int                Signal_ZigZag_Deviation =5;
input int                Signal_ZigZag_Backstep  =3;
input double             Signal_ZigZag_RRRatio   =2.0;
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

// --- Custom class de ptrs de fcts
double       arrayMA0[], arrayMA1[];
double       arrayMACDMain0[], arrayMACDMain1[], arrayMACDState0[], arrayMACDState1[], arrayMACDSignal0[], arrayMACDSignal1[];
double       arrayDealPrice[], arrayDealProfit[], arrayDealSwap[];
double       arrayMaxInterCandles[], arrayMinInterCandles[];
double       arrayOrderSL[], arrayOrderTP[];
int          arrayDealType[];
MqlDateTime  arrayDateTime[];
int totalDeals, totalHistDeals;

//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CSignalCustomMA1     *filter0;
CSignalCustomMACD1   *filter1;
CSignalCustomZigZag1 *signalzz;

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   totalHistDeals = 0;
   totalDeals = HistoryOrdersTotal();
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   signalzz=new CSignalCustomZigZag1;
   if(signalzz==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signalzz);
   signalzz.ThresholdOpen(Signal_ThresholdOpen);    // set m_threshold_open
   signalzz.ThresholdClose(Signal_ThresholdClose);  // set m_threshold_close
   signalzz.PriceLevel(Signal_PriceLevel);          // set m_price_level
   signalzz.StopLevel(Signal_StopLevel);            // set m_stop_level
   signalzz.TakeLevel(Signal_TakeLevel);            // set m_take_level
   signalzz.Expiration(Signal_Expiration);          // set m_expiration
   signalzz.Depth(Signal_ZigZag_Depth);             // set zigzag m_depth
   signalzz.Deviation(Signal_ZigZag_Deviation);     // set zigzag m_deviation
   signalzz.Backstep(Signal_ZigZag_Backstep);       // set zigzag m_backstep
   signalzz.RiskRewardRatio(Signal_ZigZag_RRRatio); // set zigzag m_riskRewardRatio
   
//--- Creating filter CSignalMA
   filter0=new CSignalCustomMA1;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signalzz.AddFilter(filter0);
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
   filter1 = new CSignalCustomMACD1;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signalzz.AddFilter(filter1);
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
    ExtExpert.OnTradeProcess(true);
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string destFolder = "DataAnalysis\\"
               + Expert_Title + "_20210404_"+Symbol() + "_" + IntegerToString(Period())
               + "_MA_" + IntegerToString(Signal_MA_PeriodMA) 
               + "_MACD_" + IntegerToString(Signal_MACD_PeriodFast) 
               + "_" + IntegerToString(Signal_MACD_PeriodSlow) 
               + "_" + IntegerToString(Signal_MACD_PeriodSignal) + "\\";
               
   ExtExpert.Deinit();
   
   CFileSaveDatanalysis DataAnalysis(destFolder,"t");
   DataAnalysis.AddDouble(arrayMA0,             "MA0");
   DataAnalysis.AddDouble(arrayMA1,             "MA1");
   DataAnalysis.AddDouble(arrayMACDMain0,       "MACDMain0");
   DataAnalysis.AddDouble(arrayMACDMain1,       "MACDMain1");
   DataAnalysis.AddDouble(arrayMACDSignal0,     "MACDSignal0");
   DataAnalysis.AddDouble(arrayMACDSignal1,     "MACDSignal1");
   DataAnalysis.AddDouble(arrayMACDState0,      "MACDState0");
   DataAnalysis.AddDouble(arrayMACDState1,      "MACDState1");
   DataAnalysis.AddInt(arrayDealType,           "DealType");
   DataAnalysis.AddDouble(arrayDealProfit,      "DealProfit");
   DataAnalysis.AddDouble(arrayMaxInterCandles, "MaxPriceDeal");
   DataAnalysis.AddDouble(arrayMinInterCandles, "MinPriceDeal");
   DataAnalysis.AddDouble(arrayOrderSL,         "OrderSL");
   DataAnalysis.AddDouble(arrayOrderTP,         "OrderTP");
   DataAnalysis.AddDouble(arrayDealSwap,        "DealSwap");
   DataAnalysis.AddDouble(arrayDealPrice,       "DealPrice");
   DataAnalysis.AddDatetime(arrayDateTime);
   DataAnalysis.RecordData();
   
   
   delete filter0;
   delete filter1;
   delete signalzz;
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
   
   //int zzHighIndex = signalzz.LastHighIndex();
   //int zzLowIndex  = signalzz.LastLowIndex();
   //double zzHigh   = signalzz.LastHigh();
   //double zzLow    = signalzz.LastLow();
   
   int posBuff = HistoryOrdersTotal();
   int diff = posBuff - totalDeals;
   for(int i=0;i<diff;i++)
   {
      totalHistDeals+=1;
      
      ArrayResize(arrayMA0,            totalHistDeals);
      ArrayResize(arrayMA1,            totalHistDeals);
      ArrayResize(arrayMACDMain0,      totalHistDeals);
      ArrayResize(arrayMACDMain1,      totalHistDeals);
      ArrayResize(arrayMACDState0,     totalHistDeals);
      ArrayResize(arrayMACDState1,     totalHistDeals);
      ArrayResize(arrayMACDSignal0,    totalHistDeals);
      ArrayResize(arrayMACDSignal1,    totalHistDeals);
      ArrayResize(arrayDealType,       totalHistDeals);
      ArrayResize(arrayDealProfit,     totalHistDeals);
      ArrayResize(arrayDateTime,       totalHistDeals);
      ArrayResize(arrayMaxInterCandles,totalHistDeals);
      ArrayResize(arrayMinInterCandles,totalHistDeals);
      ArrayResize(arrayOrderSL,        totalHistDeals);
      ArrayResize(arrayOrderTP,        totalHistDeals);
      ArrayResize(arrayDealSwap,       totalHistDeals);
      ArrayResize(arrayDealPrice,      totalHistDeals);
      
      
      arrayMA0[totalHistDeals-1]             = filter0.MA(1)    ;
      arrayMA1[totalHistDeals-1]             = filter0.MA(2)    ;
      arrayMACDMain0[totalHistDeals-1]       = filter1.Main(1)  ; 
      arrayMACDMain1[totalHistDeals-1]       = filter1.Main(2)  ;
      arrayMACDState0[totalHistDeals-1]      = filter1.State(1) ;
      arrayMACDState1[totalHistDeals-1]      = filter1.State(2) ;
      arrayMACDSignal0[totalHistDeals-1]     = filter1.Signal(1);
      arrayMACDSignal1[totalHistDeals-1]     = filter1.Signal(2);
      
      ulong dealTicket                       = HistoryDealGetTicket(totalHistDeals);
      //ulong orderTicket                      = HistoryOrderGetTicket(totalHistDeals-1);
      TimeToStruct((datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME),arrayDateTime[totalHistDeals-1]);
      long dealType                          = HistoryDealGetInteger(dealTicket,DEAL_TYPE);
      if(dealType==DEAL_TYPE_BUY) 
             arrayDealType[totalHistDeals-1] = 1;
      else if(dealType==DEAL_TYPE_SELL) 
             arrayDealType[totalHistDeals-1] = -1;
      else 
      {
         Print("############## Error bad deal type");
         arrayDealType[totalHistDeals-1]     = 0;
      }
      arrayDealType[totalHistDeals-1]       +=(ArraySize(arrayDealType)>1)?arrayDealType[totalHistDeals-2]:0 ;
      arrayDealProfit[totalHistDeals-1]      = HistoryDealGetDouble(dealTicket,DEAL_PROFIT);
      arrayDealSwap[totalHistDeals-1]        = HistoryDealGetDouble(dealTicket,DEAL_SWAP);
      arrayDealPrice[totalHistDeals-1]       = HistoryDealGetDouble(dealTicket,DEAL_PRICE);
      arrayOrderSL[totalHistDeals-1]         = HistoryOrderGetDouble(dealTicket,ORDER_SL);
      arrayOrderTP[totalHistDeals-1]         = HistoryOrderGetDouble(dealTicket,ORDER_TP);
      
      
      // bar min/max interval iHighest MqlDateTime
      datetime prevTime                      = (ArraySize(arrayMinInterCandles)>1)?StructToTime(arrayDateTime[totalHistDeals-2]):StructToTime(arrayDateTime[totalHistDeals-1]);
      int barIndex                           = iBarShift(_Symbol,_Period, prevTime,false);
      int highIdx                            = iHighest(_Symbol,_Period,MODE_HIGH,barIndex+1);
      int lowIdx                             = iLowest(_Symbol,_Period,MODE_LOW,barIndex+1);
      arrayMaxInterCandles[totalHistDeals-1] = iHigh(_Symbol,_Period,highIdx);
      arrayMinInterCandles[totalHistDeals-1] = iLow(_Symbol,_Period,lowIdx);
      
   }
   totalDeals = posBuff;
      
   
      
  }
  
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+

void OnTesterDeinit()
  {
   // sauvegarder ficgier de données sur les postitons ouvertes
   
  }
