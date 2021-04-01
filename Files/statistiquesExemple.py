import numpy as np
from math import ceil, floor
import matplotlib
import matplotlib.pyplot as plt
from datetime import datetime

path = "C:/Users/PC HP/AppData/Roaming/MetaQuotes/Terminal/Common/Files/DataAnalysis/EA_test1_autogenerate_20210329_MA_200_MACD_12_26_9/"

doublesFile = open(path+"DoublesSignals.csv")
doubleSignals = np.genfromtxt(path+"DoublesSignals.csv",delimiter=";")
print("###############")
#print(doubleSignals)
print(doubleSignals.shape, ' ', doubleSignals.dtype)
doublesFile.close()

Titres = np.array([])
#print(Titres)
TitresFile = open(path+"SignalNames.csv")
#print(TitresFile.read())
TitresLines = TitresFile.readlines()
for line in TitresLines:
    Titres = np.append(Titres,line.strip())
    print(line.strip())
print("###############")
print(Titres)
print(Titres.shape, ' ', Titres.dtype)
#print(Titres[9])
TitresFile.close()

DictSignals = {}
for label, array in zip(Titres, doubleSignals):
    DictSignals[label]=array
    print(label,array.shape)

DatetimeFile = open(path+"Datetime.csv")
DatetimeRawData = np.genfromtxt(path+"Datetime.csv",delimiter=";").astype(np.int)
print("###############")
#print(DatetimeRawData)
print(DatetimeRawData.shape, ' ', DatetimeRawData.dtype)
DatetimeFile.close()

DatetimeLabels = ['dayOfYear','dayOfWeek','year','month','day','hour','min','sec']

print('###################')
DictDatetime = {}
for label, array in zip(DatetimeLabels, np.transpose(DatetimeRawData)):
    DictDatetime[label] = array
#print(dictDatetime)
                  
ListDatetime = [datetime(DictDatetime['year'][i]
                        ,DictDatetime['month'][i]
                        ,DictDatetime['day'][i]
                        ,DictDatetime['hour'][i]
                        ,DictDatetime['min'][i]
                        ,DictDatetime['sec'][i]) for i in range(DatetimeRawData.shape[0])]

'''print(len(listDatetime))

fig, ax = plt.subplots()
matplotlib.rcParams.update({'font.size': 6})
ax.plot(listDatetime,np.cumsum(doubleSignals[9,:],axis=0))
ax.set(xlabel='datetime', ylabel='Moolah ($)',
       title=Titres[9])
#ax.yaxis.set_ticks(np.arange(44)*25-1065)
#ax.xaxis.set_ticks([])
ax.grid()
fig.savefig("figure1.png",dpi=300)
plt.show()'''

print('\n\n ----------------------------\n'
         ,'|  Calcul de statistiques  |\n'
        ,'----------------------------')

def sumDatetime(array):
    sum_ = array[0]
    for i in array[1:]:
        sum_ += i
    return sum_


# Calculs de statistiques
ClosedPosArray            = DictSignals['DealProfit'][1::2]
#print(ClosedPosArray)
ClosedPosDatetimeInterval = list(j-i for i,j in zip(ListDatetime[::2],ListDatetime[1::2]))
#print(closedPosDatetime[0])

GainArray    = ClosedPosArray[ClosedPosArray>0]
GainDatetime = [ClosedPosDatetimeInterval[i] for i in np.where(ClosedPosArray>0)[0].tolist()]
NbGain       = GainArray.shape[0]
LossArray    = ClosedPosArray[ClosedPosArray<0]
LossDatetime = [ClosedPosDatetimeInterval[i] for i in np.where(ClosedPosArray<0)[0].tolist()]
NbLoss       = LossArray.shape[0]
#print(gainsArray.shape,len(gainsDatetime),' ',lossesArray.shape,len(lossesDatetime))

# Calcul gain moyen
MeanGain      = np.sum(GainArray)/NbGain
TempsMeanGain = sumDatetime(GainDatetime)/NbGain
# Calcul perte moyenne
MeanLoss      = np.sum(LossArray)/NbLoss
TempsMeanLoss = sumDatetime(LossDatetime)/NbLoss
print('Nb gains : ',NbGain,',   gain moyen : ',MeanGain)
print('Temps gain moyen :',TempsMeanGain, " (On perte plus vite qu'on ne gagne)")
print('Nb pertes: ',NbLoss,', perte moyenne: ',MeanLoss)
print('Temps perte moyenne :',TempsMeanLoss, " (On perte plus vite qu'on ne gagne)")

# Calcul ratio gain/perte
GainLossRatio = MeanLoss/MeanLoss
print('Ratio Gain pertes :',GainLossRatio, " (la c'est naze !!!)")

#%% Calcul du pourcentage de Tr gagnant
WinPerc  = NbGain/ClosedPosArray.shape[0]*100
# Calcul du pourcentage de Tr perdant
LossPerc = NbLoss/ClosedPosArray.shape[0]*100
print('Win%  : ',WinPerc)
print('Loss% : ',LossPerc)

#%% Calcul de l'esperance
Expectency = (WinPerc*MeanGain+LossPerc*MeanLoss)/100
print('Esperance :',Expectency)

# Bonus : Calcul de var de gains et pertes
MeanGainVarSpd = MeanGain / (TempsMeanGain.total_seconds()/3600.)
MeanLossVarSpd = MeanLoss / (TempsMeanLoss.total_seconds()/3600.)
print('Vitesse Gain Moyen ($/h) : ',MeanGainVarSpd)
print('Vitesse Perte Moyen ($/h) : ',MeanLossVarSpd)
#%% date.weekday(), date.hour()
# hist : achat vente gain loss jour

'''for elem in ListDatetime:
    print(elem.weekday(), elem.hour, elem.min, elem.timestamp())'''
'''print(ClosedPosDatetimeInterval[0].total_seconds())'''

OpenPosDatetime   = ListDatetime[::2]
ClosedPosDatetime = ListDatetime[1::2]

ListDealType = DictSignals['DealType'][::2]

BuyGainArr  = np.zeros((7*24))
BuyLossArr  = np.zeros((7*24))
SellGainArr = np.zeros((7*24))
SellLossArr = np.zeros((7*24))

def getWeekHour(date):
    weekday = date.weekday()
    hour    = date.hour
    minute  = date.minute
    second  = date.second
    return  weekday*24.+ hour + minute/60. + second/60./60

def getHourHistArray(i):
    if   ((ClosedPosArray[i]>0) and (ListDealType[i]>0)): 
        return BuyGainArr
    elif ((ClosedPosArray[i]>0) and (ListDealType[i]<0)): 
        return SellGainArr
    elif ((ClosedPosArray[i]<0) and (ListDealType[i]>0)): 
        return BuyLossArr
    elif ((ClosedPosArray[i]<0) and (ListDealType[i]<0)): 
        return SellLossArr
# verifier tout ça
for i, opentime in enumerate(OpenPosDatetime):
    weekHourValueInit = getWeekHour(opentime)
    idxInit           = ceil(weekHourValueInit)
    fracInit          = idxInit - weekHourValueInit
    
    weekHourValueEnd  = weekHourValueInit + ClosedPosDatetimeInterval[i].total_seconds()/60./60.
    idxEnd            = floor(weekHourValueEnd)
    fracEnd          = weekHourValueEnd - idxEnd
    
    arr = getHourHistArray(i)
    arr[idxInit-1]+=fracInit
    for j in range(idxInit,idxEnd):
        arr[j%(7*24)] += 1
    arr[idxEnd%(7*24)]+=fracEnd

GainArr      =  BuyGainArr+SellGainArr
LossArr      = -BuyLossArr-SellLossArr
TotalDealArr = BuyGainArr+SellGainArr+BuyLossArr+SellLossArr
NormGainArr  = GainArr/TotalDealArr
NormLossArr  = LossArr/TotalDealArr

#https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.bar.html
# normalisation ?
'''y_pos = np.arange(7*24)
fig, ax = plt.subplots()
matplotlib.rcParams.update({'font.size': 6})
ax.bar(y_pos,NormGainArr)
ax.bar(y_pos,NormLossArr)
#ax.xticks(y_pos,y_pos%24)
ax.set(xlabel='datetime', ylabel='Moolah ($)',
       title='LossArr')#,ylim=([-23,17]))
fig.savefig("LossArr.png",dpi=300)
plt.show()'''

# normalisé
'''y_pos = np.arange(7*24)
fig, ax = plt.subplots()
matplotlib.rcParams.update({'font.size': 6})
ax.bar(y_pos,NormGainArr)
ax.bar(y_pos,NormLossArr)
#ax.xticks(y_pos,y_pos%24)
ax.set(xlabel='datetime', ylabel='Moolah ($)',
       title='LossArr')#,ylim=([-23,17]))
fig.savefig("LossArr.png",dpi=300)
plt.show()'''
# peut etre stats par années (dans un futur proche)


#%% stat sur moovin average
DeltaMA = DictSignals['MA0'][::2] - DictSignals['MA1'][::2]

DeltaMABuyGainArr  = DeltaMA[np.logical_and((ClosedPosArray>0),(ListDealType>0))]
DeltaMABuyLossArr  = DeltaMA[np.logical_and((ClosedPosArray<0),(ListDealType>0))]
DeltaMASellGainArr = DeltaMA[np.logical_and((ClosedPosArray>0),(ListDealType<0))]
DeltaMASellLossArr = DeltaMA[np.logical_and((ClosedPosArray<0),(ListDealType<0))]

print(DeltaMABuyGainArr.shape,
      DeltaMABuyLossArr.shape,
      DeltaMASellGainArr.shape,
      DeltaMASellLossArr.shape)

n, bins, patches = plt.hist(np.append(DeltaMABuyLossArr,-DeltaMASellLossArr),50)
n, bins, patches = plt.hist(np.append(DeltaMABuyGainArr,-DeltaMASellGainArr),50)

plt.plot()
plt.show()

'''n, bins, patches = plt.hist(np.append(DeltaMABuyLossArr,-DeltaMASellLossArr),50)
plt.plot()
plt.show()'''





