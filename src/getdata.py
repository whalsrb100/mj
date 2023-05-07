#pylint:disable=W0702
import json
import requests
import os
import random

# Sort Function
def keysort(x): return x[0]
def valsort(x): return x[1]

class MyApp:
    def Define(self,setpath):
        self.PATH = setpath
        self.filename = self.PATH + '/data.json'
        self.URL = 'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo='
        self.data = {}
        self.data['list'] = []
        self.data['latest'] = 0
        self.StartNum = 1
        self.LastNum = 1
        self.ExecuteLoadInfo = True
        self.ExecuteSaveInfo = True
        self.debugInfo = False
        self.num=['drwNo','drwtNo1','drwtNo2','drwtNo3','drwtNo4','drwtNo5','drwtNo6','bnusNo']
        self.view = []
        self.numsinfo={}

    def __init__(self,datapath='data'):
        super().__init__()
        self.Define(datapath)
        self.LoadData()
        self.GetData()
        self.SaveData()

    def LoadData(self):
        self.StartNum = 1
        self.LastNum = self.StartNum + 3000
        if self.ExecuteLoadInfo:
            if os.path.isfile(self.filename):
                with open(self.filename, 'r') as jsonfile:
                    self.data = json.load(jsonfile)
                if self.debugInfo:
                    print("[    OK    ] LoadData")
                self.StartNum = int(self.data['latest']) + 1
                self.LastNum = self.StartNum + 99999
                return True
        if self.debugInfo:
            print("[  FAIL  ] LoadData")
        return False

    def GetData(self):
        cnt = 0
        for i in range(self.StartNum, self.LastNum+1):
            try:
                response = requests.get(self.URL+str(i))
                result = response.json()
                if result['returnValue'] == 'success':
                    if self.data['latest'] < int(result['drwNo']):
                        self.data['latest'] = int(result['drwNo'])
                        self.data['list'].append(result)
                    if self.debugInfo:
                        print("[    OK    ] GetData")
                else: break
                cnt = cnt + 1
            except:
                if self.debugInfo:
                    print("[  FAIL  ] GetData")
                if cnt == 0:
                    self.ExecuteSaveInfo = False
                break

    def SaveData(self):
        if self.ExecuteSaveInfo:
            with open(self.filename, 'w') as outfile:
                json.dump(self.data, outfile, indent = 4)
            if self.debugInfo:
                print("[    OK    ] SaveData")
            return True
        else:
            if self.debugInfo:
                print("[  FAIL  ] SaveData")

    def PrintAll(self):
        Lnum=int(self.data['latest'])
        for i in range(0,Lnum):
            print("{} - {:>4}".format(str(self.data['list'][i]['drwNoDate']), str(self.data['list'][i]['drwNo'])),end=' ')
            for j in range(1,7 + 1):
                print("{:>3}".format(str((int(self.data['list'][i][self.num[j]])))),end=' ')
            print()

    def PrintSeq(self,seq):
        print("{} - {:>4}".format(str(self.data['list'][seq-1]['drwNoDate']), str(self.data['list'][seq-1]['drwNo'])),end=' ')
        for j in range(1,7 + 1):
            print("{:>3}".format(str((int(self.data['list'][seq-1][self.num[j]])))),end=' ')
        print()

if __name__ == "__main__":
    app = MyApp('../data')
    app.PrintAll()
