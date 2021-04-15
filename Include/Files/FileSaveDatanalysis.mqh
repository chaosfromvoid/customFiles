//+------------------------------------------------------------------+
//|                                          FileSaveDatanalysis.mqh |
//|            Fabien Amazo based on Copyright 2021, MetaQuotes Ltd. |
//|                     https://github.com/chaosfromvoid/customFiles |
//+------------------------------------------------------------------+
#property copyright "Fabien Amazo based on Copyright 2021, MetaQuotes Ltd."
#property link      "https://github.com/chaosfromvoid/customFiles"
#property version   "1.00"
#include "FileArray2Csv.mqh"

class CFileSaveDatanalysis
  {
private:
   string            m_destFolder;
   string            m_prefix;
   CFileArray2Csv *  m_signalNames;
   CFileArray2Csv *  m_datetimeFile;
   CFileArray2Csv *  m_doubleSignals;

public:
                     CFileSaveDatanalysis(string dest,string prefix);
                    ~CFileSaveDatanalysis();
   void              AddInt(int &array[], string SignalName);
   void              AddDouble(double &array[], string signalName);
   void              AddDatetime(MqlDateTime &array[]);
   void              RecordData();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFileSaveDatanalysis::CFileSaveDatanalysis(string dest,string prefix):
                                                                    m_destFolder(dest),
                                                                    m_prefix(prefix),
                                                                    m_signalNames(NULL),
                                                                    m_datetimeFile(NULL),
                                                                    m_doubleSignals(NULL)
                                                                    {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFileSaveDatanalysis::~CFileSaveDatanalysis()
  {
   if(m_signalNames!=NULL)
     {
      delete(m_signalNames);
     }
   if(m_datetimeFile!=NULL)
     {
      delete(m_datetimeFile);
     }
   if(m_doubleSignals!=NULL)
     {
      delete(m_doubleSignals);
     }
  }
//+------------------------------------------------------------------+

void CFileSaveDatanalysis::AddInt(int &array[], string SignalName)
  {
   if(m_doubleSignals == NULL)
     {
      m_doubleSignals = new CFileArray2Csv(m_destFolder+"DoublesSignals.csv");
     }
   m_doubleSignals.AddArray(array);
   ArrayFree(array);
   if(m_signalNames == NULL)
     {
      m_signalNames = new CFileArray2Csv(m_destFolder+"SignalNames.csv");
     }
   string a[1];
   a[0] = SignalName;
   m_signalNames.AddArray(a);
  }
  
//+------------------------------------------------------------------+

void CFileSaveDatanalysis::AddDouble(double &array[], string SignalName)
  {
   if(m_doubleSignals == NULL)
     {
      m_doubleSignals = new CFileArray2Csv(m_destFolder+"DoublesSignals.csv");
     }
   m_doubleSignals.AddArray(array);
   ArrayFree(array);
   if(m_signalNames == NULL)
     {
      m_signalNames = new CFileArray2Csv(m_destFolder+"SignalNames.csv");
     }
   string a[1];
   a[0] = SignalName;
   m_signalNames.AddArray(a);
  }
  
//+------------------------------------------------------------------+

void CFileSaveDatanalysis::AddDatetime(MqlDateTime &array[])
  {
   if(m_datetimeFile == NULL)
     {
      m_datetimeFile = new CFileArray2Csv(m_destFolder+"Datetime.csv");
     }
   m_datetimeFile.AddArray(array);
  }

void CFileSaveDatanalysis::RecordData(void)
  {
   m_doubleSignals.RecordFile();
   m_datetimeFile.RecordFile();
   m_signalNames.RecordFile();
  }
 
/*void CFileSaveDatanalysis::RecordCharts()
  {
   hChart=ChartOpen(Symbol(),0);
   ChartSetInteger(hChart,CHART_MODE,CHART_CANDLES);            // Candlestick
   
   ChartSetInteger(hChart,CHART_AUTOSCROLL,true);            // autoscroll enabled
   ChartSetInteger(hChart,CHART_COLOR_BACKGROUND,White);     // white background
   ChartSetInteger(hChart,CHART_COLOR_FOREGROUND,Black);     // axes and labels are black
   ChartSetInteger(hChart,CHART_SHOW_OHLC,false);            // OHLC are not shown
   ChartSetInteger(hChart,CHART_SHOW_BID_LINE,true);         // show BID line
   ChartSetInteger(hChart,CHART_SHOW_ASK_LINE,false);        // hide ASK line
   ChartSetInteger(hChart,CHART_SHOW_LAST_LINE,false);       // hide LAST line
   ChartSetInteger(hChart,CHART_SHOW_GRID,true);             // show grid
   ChartSetInteger(hChart,CHART_SHOW_PERIOD_SEP,true);       // show period separators
   ChartSetInteger(hChart,CHART_COLOR_GRID,LightGray);       // grid is light-gray
   ChartSetInteger(hChart,CHART_COLOR_CHART_LINE,Black);     // chart lines are black
   ChartSetInteger(hChart,CHART_COLOR_CHART_UP,Black);       // up bars are black
   ChartSetInteger(hChart,CHART_COLOR_CHART_DOWN,Black);     // down bars are black
   ChartSetInteger(hChart,CHART_COLOR_BID,Gray);             // BID line is gray
   ChartSetInteger(hChart,CHART_COLOR_VOLUME,Green);         // volumes and orders levels are green
   ChartSetInteger(hChart,CHART_COLOR_STOP_LEVEL,Red);       // SL and TP levels are red
   ChartSetString(hChart,CHART_COMMENT,ChartSymbol(hChart)); // comment contains instrument
   ChartScreenShot(hChart,"picture2.gif",Picture2_width,Picture2_height); // save chart as image file
  }*/