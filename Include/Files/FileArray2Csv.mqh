//+------------------------------------------------------------------+
//|                                                FileArray2Csv.mqh |
//|            Fabien Amazo based on Copyright 2021, MetaQuotes Ltd. |
//|                     https://github.com/chaosfromvoid/customFiles |
//+------------------------------------------------------------------+
#property copyright "Fabien Amazo based on Copyright 2021, MetaQuotes Ltd."
#property link      "https://github.com/chaosfromvoid/customFiles"
#property version   "1.00"

#include "FileTxt.mqh"

/*
ENUM_DATATYPE

Identifier  Data type

TYPE_BOOL     bool
TYPE_CHAR     char
TYPE_UCHAR    uchar
TYPE_SHORT    short
TYPE_USHORT   ushort
TYPE_COLOR    color
TYPE_INT      int
TYPE_UINT     uint
TYPE_DATETIME datetime
TYPE_LONG     long
TYPE_ULONG    ulong
TYPE_FLOAT    float
TYPE_DOUBLE   double
TYPE_STRING   string
*/

class CFileArray2Csv : public CFileTxt
  {
protected:
   ENUM_DATATYPE     m_csvType;
   string            m_fileName;
   string            m_text;
   string            m_separator;
   //int               m_size; // a implementer
public:
                     CFileArray2Csv();
                     CFileArray2Csv(string fileTitle);
                    ~CFileArray2Csv();
   void              SetTitle(string title);
   bool              AddArray(double &array[]);
   bool              AddArray(int &array[]);
   bool              AddArray(string &array[]);
   bool              AddArray(MqlDateTime &array[]);
   bool              RecordFile();
   int               Open();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFileArray2Csv::CFileArray2Csv():m_csvType(TYPE_COLOR),m_text(""),m_separator(";"),m_fileName("")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFileArray2Csv::CFileArray2Csv(string fileTitle):m_csvType(TYPE_COLOR),m_text(""),m_separator(";"),m_fileName(fileTitle)
  {
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFileArray2Csv::~CFileArray2Csv()
  {
  }
//+------------------------------------------------------------------+
//|Fonction d'ajout de texte                                         |
//+------------------------------------------------------------------+
void CFileArray2Csv::SetTitle(string title)
  {
   m_fileName = title;
  }

bool CFileArray2Csv::AddArray(double &array[])
  {
   if(m_csvType==TYPE_COLOR)
      m_csvType = TYPE_DOUBLE;
   else if(m_csvType!=TYPE_DOUBLE && m_csvType!=TYPE_INT)
    {
      Print("Error data type, expected TYPE_DOUBLE");
      return true;
    }
   int size = ArraySize(array);
   m_text += (size>0)?DoubleToString(array[0]):"";
   for(int i=1;i<size;i++)
    {
      m_text += m_separator + DoubleToString(array[i]);
    }
   m_text += "\n";
   return false;
  }
bool CFileArray2Csv::AddArray(int &array[])
  {
   if(m_csvType==TYPE_COLOR)
      m_csvType = TYPE_INT;
   else if(m_csvType!=TYPE_INT && m_csvType!=TYPE_DOUBLE)
    {
      Print("Error data type, expected TYPE_INT");
      return true;
    }
   int size = ArraySize(array);
   m_text += (size>0)?IntegerToString(array[0]):"";
   for(int i=1;i<size;i++)
    {
      m_text += m_separator + IntegerToString(array[i]);
    }
   m_text += "\n";
   return false;
  }
bool CFileArray2Csv::AddArray(string &array[])
  {
   if(m_csvType==TYPE_COLOR)
      m_csvType = TYPE_STRING;
   else if(m_csvType!=TYPE_STRING)
    {
      Print("Error data type, expected TYPE_STRING");
      return true;
    }
   int size = ArraySize(array);
   m_text += (size>0)?array[0]:"";
   for(int i=1;i<size;i++)
    {
      m_text += m_separator + array[i];
    }
   m_text += "\n";
   return false;
  }
bool CFileArray2Csv::AddArray(MqlDateTime &array[])
  {
   if(m_csvType==TYPE_COLOR)
      m_csvType = TYPE_DATETIME;
   else if(m_csvType!=TYPE_DATETIME)
    {
      Print("Error data type, expected TYPE_DATETIME");
      return true;
    }
   int size = ArraySize(array);
   m_text += (size>0)?(IntegerToString(array[0].day_of_year) +";"+
                       IntegerToString(array[0].day_of_week) +";"+
                       IntegerToString(array[0].year)        +";"+
                       IntegerToString(array[0].mon)         +";"+
                       IntegerToString(array[0].day)         +";"+
                       IntegerToString(array[0].hour)        +";"+
                       IntegerToString(array[0].min)         +";"+
                       IntegerToString(array[0].sec)):"";
   for(int i=1;i<size;i++)
    {
      m_text += "\n" + IntegerToString(array[i].day_of_year) +";"+
                       IntegerToString(array[i].day_of_week) +";"+
                       IntegerToString(array[i].year)        +";"+
                       IntegerToString(array[i].mon)         +";"+
                       IntegerToString(array[i].day)         +";"+
                       IntegerToString(array[i].hour)        +";"+
                       IntegerToString(array[i].min)         +";"+
                       IntegerToString(array[i].sec);
    }
   
   return false;
  }

bool CFileArray2Csv::RecordFile(void)
  {
   if(CFileTxt::Open(m_fileName,FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON)<0)
   {
      Print("Error code ",GetLastError());
   }
   FileWriteString(m_handle,m_text);
   return false;
  }
