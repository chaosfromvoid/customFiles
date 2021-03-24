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
   string            m_text;
public:
                     CFileArray2Csv();
                    ~CFileArray2Csv();
   bool              AddArray(double &array[]);
   bool              AddArray(int &array[]);
   bool              AddArray(string &array[]);
   bool              AddArray(datetime &array[]);
   bool              RecordFile();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFileArray2Csv::CFileArray2Csv():m_csvType(TYPE_COLOR),m_text("")
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
   m_text += (size>0)?array[0]:"";
   for(int i=1;i<size;i++)
    {
      m_text += ";" + array[i];
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
   m_text += (size>0)?array[0]:"";
   for(int i=1;i<size;i++)
    {
      m_text += ";" + array[i];
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
      m_text += ";" + array[i];
    }
   m_text += "\n";
   return false;
  }
bool CFileArray2Csv::AddArray(datetime &array[])
  {
   if(m_csvType==TYPE_COLOR)
      m_csvType = TYPE_DATETIME;
   else if(m_csvType!=TYPE_DATETIME)
    {
      Print("Error data type, expected TYPE_DATETIME");
      return true;
    }
   int size = ArraySize(array);
   m_text += (size>0)?array[0]:"";
   for(int i=1;i<size;i++)
    {
      m_text += ";" + array[i];
    }
   m_text += "\n";
   return false;
  }

bool CFileArray2Csv::RecordFile(void)
  {
   FileWriteString(m_handle,m_text);
   return false;
  }