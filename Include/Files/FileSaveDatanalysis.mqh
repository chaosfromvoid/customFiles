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