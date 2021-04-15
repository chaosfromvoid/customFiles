//|                                          SignalCustomZigZag1.mqh |
//|            Fabien Amazo based on Copyright 2021, MetaQuotes Ltd. |
//|                     https://github.com/chaosfromvoid/customFiles |
//+------------------------------------------------------------------+
#property copyright "Fabien Amazo based on Copyright 2021, MetaQuotes Ltd."
#property link      "https://github.com/chaosfromvoid/customFiles"
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator 'Custom ZigZag 1'                     |
//| Type=SignalAdvanced                                              |
//| Name=ZigZag (Custom 1)                                           |
//| ShortName=CustomZigZag1                                          |
//| Class=CSignalCustomZigZag                                        |
//| Page=signal_custom_zz                                            |
//| Parameter=Depth,int,12,Depth                                     |
//| Parameter=Deviation,int,5,Deviation                              |
//| Parameter=Backstep,int,3,Backstep                                |
//| Parameter=Risk reward ratio,double,2.,RiskRewardRatio            |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalCustomZigZag1.                                      |
//| Purpose: Class of generator of trade entries based on            |
//|          the 'CustomZigZag1' indicator.                          |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+

class CSignalCustomZigZag1 : public CExpertSignal
  {
private:
   CiCustom          m_zigzag; // The indicator as an object
   //--- Configurable module parameters
   int               m_depth;
   int               m_deviation;
   int               m_backstep;
   //--- Risk reward ratio
   double            m_riskRewardRatio;
public:
   //--- Constructor of class
                     CSignalCustomZigZag1(void);
                     CSignalCustomZigZag1(int depth, int deviation, int backstep, double riskRewardRatio);
   //--- Destructor of class
                    ~CSignalCustomZigZag1(void);
   //--- Methods for placing
   void              Depth(int depth)                          {m_depth           = depth;          }
   void              Deviation(int deviation)                  {m_deviation       = deviation;      }
   void              Backstep(int backstep)                    {m_backstep        = backstep;       }
   void              RiskRewardRatio(double riskRewardRatio)   {m_riskRewardRatio = riskRewardRatio;}
   //--- Checking correctness of input data
   bool              ValidationSettings(void);
   //--- Creating indicators and timeseries for the module of signals
   bool              InitIndicators(CIndicators *indicators);   
   //--- Access to indicator data
   int               LastHighIndex(void) const {return((int)m_zigzag.GetData(3,0));}
   int               LastLowIndex(void)  const {return((int)m_zigzag.GetData(4,0));}
   double            LastHigh(void)      const {return(m_zigzag.GetData(1,LastHighIndex()));}
   double            LastLow(void)       const {return(m_zigzag.GetData(2,LastLowIndex()));}
   //--- methods for detection of levels of entering the market
   virtual bool      OpenLongParams(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      OpenShortParams(double &price,double &sl,double &tp,datetime &expiration);
protected:
   //--- Creating MA indicators
   bool              CreateZigZag(CIndicators *indicators);
  };
//+------------------------------------------------------------------+
//| Constructors                                                     |
//+------------------------------------------------------------------+
CSignalCustomZigZag1::CSignalCustomZigZag1(void) : m_depth(12),
                                                 m_deviation(5),
                                                 m_backstep(3),
                                                 m_riskRewardRatio(2.)
  {
  }
  
CSignalCustomZigZag1::CSignalCustomZigZag1(int depth, int deviation, int backstep, double riskRewardRatio): 
                                                 m_depth(depth),
                                                 m_deviation(deviation),
                                                 m_backstep(backstep),
                                                 m_riskRewardRatio(riskRewardRatio)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalCustomZigZag1::~CSignalCustomZigZag1(void)
  {
  }
//+------------------------------------------------------------------+
//| Checks input parameters and returns true if everything is OK     |
//+------------------------------------------------------------------+
bool CSignalCustomZigZag1::ValidationSettings(void)
  {
//--- Call the base class method
   if(!CExpertSignal::ValidationSettings()) return(false);
//--- Add verification settings

//--- All checks are completed, everything is ok
   return true;
  }
//+------------------------------------------------------------------+
//| Creates indicator                                                |
//| Input:  a pointer to a collection of indicators                  |
//| Output: true if successful, otherwise false                      |
//+------------------------------------------------------------------+
bool CSignalCustomZigZag1::InitIndicators(CIndicators *indicators)
  {
//--- Standard check of the collection of indicators for NULL
   if(indicators==NULL) return(false);
//--- Initializing indicators and timeseries in additional filters
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- Creating our MA indicators
   if(!CreateZigZag(indicators))                  return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the "ZigZag " indicator                                  |
//+------------------------------------------------------------------+
bool CSignalCustomZigZag1::CreateZigZag(CIndicators *indicators)
  {
//--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_zigzag)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast MA");
      return(false);
     }
//--- Setting parameters of the fast MA
   MqlParam parameters[4];
//---

   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="CustomIndicators\\CustomZigZag1";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_depth;      // Depth
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=m_deviation;  // Deviation
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_backstep;   // Backstep
//--- Object initialization
   if(!m_zigzag.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the fast MA");
      return(false);
     }
//--- Number of buffers
   if(!m_zigzag.NumBuffers(5)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
//+------------------------------------------------------------------+
//| Redefining "ZigZag " indicator buy sell params                   |
//+------------------------------------------------------------------+
bool CSignalCustomZigZag1::OpenLongParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   CExpertSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      double lastLow    = LastLow();
      double base_price = (m_base_price==0.0) ? m_symbol.Ask() : m_base_price;
      price             = m_symbol.NormalizePrice(base_price-m_price_level*PriceLevelUnit());
      sl                = (m_stop_level==0.0) ? 0.0 : m_symbol.NormalizePrice(lastLow);
      tp                = (m_take_level==0.0) ? 0.0 : m_symbol.NormalizePrice(price + m_riskRewardRatio*(price-lastLow));
      expiration       += m_expiration*PeriodSeconds(m_period);
      return(true);
     }
//---
   return(general.OpenLongParams(price,sl,tp,expiration));
  }
//+------------------------------------------------------------------+
//| Detecting the levels for selling                                 |
//+------------------------------------------------------------------+
bool CSignalCustomZigZag1::OpenShortParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   CExpertSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      double lastHigh   = LastHigh();
      double base_price = (m_base_price==0.0) ? m_symbol.Bid() : m_base_price;
      price             = m_symbol.NormalizePrice(base_price+m_price_level*PriceLevelUnit());
      sl                = (m_stop_level==0.0) ? 0.0 : m_symbol.NormalizePrice(lastHigh);
      tp                = (m_take_level==0.0) ? 0.0 : m_symbol.NormalizePrice(price - m_riskRewardRatio*(lastHigh-price));
      expiration       += m_expiration*PeriodSeconds(m_period);
      return(true);
     }
//---
   return(general.OpenShortParams(price,sl,tp,expiration));
  }
  