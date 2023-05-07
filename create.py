#pylint:disable=E0001
#!/usr/bin/python3.11
import src.getdata
import random
import sys



class Createnums:
	
	
	
	def Define(self,input):
		self.NUM = 6
		self.History = []
		self.app = src.getdata.MyApp()
		self.resultNum = [0,0,0,0,0,0]
		self.seq=input
		if input == 'new':
			self.seq = int(self.app.data['latest'] + 1)
		elif input == 'latest':
			self.seq = int(self.app.data['latest'])



	def __init__(self, input='new'):
		super().__init__()
		self.Define(input)
		self.historyGen(self.seq-1)
		self.Create()
		self.PrintNums()
	
	
	
	def historyGen(self,seqnum):
		for i in range(6):
			self.History.append([])
			n=i+1	
			for j in range(seqnum):
				self.History[i].append(self.app.data['list'][j][self.app.num[n]])
		
		del i
		del n
		del j
		
		

	def Create(self):
		tmp = random.choice(self.History[0])
		if tmp > self.resultNum[0]:
			self.resultNum[0] = tmp
		for i in range(1,5+1):
			isRight = False
			while not isRight:
				tmp = random.choice(self.History[i])
				if self.resultNum[i-1] < tmp:
					self.resultNum[i] = tmp
					
					
					isRight = True
					
		del tmp
		del isRight
		del i
		
		#self.resultNum.sort()
			
			
			
	def CreateCheck(self):
		pass



	def PrintNums(self):
		if len(self.app.data['list']) < self.seq:
			print("{}) Challenge Create Nums.".format(self.app.data['latest']+1))
			print("myNum)",end=' ')
			for i in range(6):
				rightChar = ''
				print("{:>4}{:<3}".format(self.resultNum[i],rightChar,),end='')
			print()
		else:
			print("{:>10}){:>6}{:>6}{:>6}{:>6}{:>6}{:>6}{:>6}{:>6}".format(self.app.data['list'][self.seq-1][self.app.num[0]],self.app.data['list'][self.seq-1][self.app.num[1]],self.app.data['list'][self.seq-1][self.app.num[2]],self.app.data['list'][self.seq-1][self.app.num[3]],self.app.data['list'][self.seq-1][self.app.num[4]],self.app.data['list'][self.seq-1][self.app.num[5]],self.app.data['list'][self.seq-1][self.app.num[6]],'/',self.app.data['list'][self.seq-1][self.app.num[7]]))
			print("myNum)",end=' ')
			for i in range(6):
				rightChar = ''
				for j in range(1,6+1):
					if self.resultNum[i]== self.app.data['list'][self.seq-1][self.app.num[j]]:
						rightChar = '*'
						break
				print("{:>4}{:<3}".format(self.resultNum[i],rightChar,),end='')
			print()
			
		del i
		del j
		del rightChar





if __name__ == "__main__":
	selSeq = 'new'
	selSeq = 1066
	app = Createnums(selSeq)
	
	del selSeq
	del app