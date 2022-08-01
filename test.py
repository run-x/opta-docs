from typing import List

class Solution:
    def numberOfCombinations(self, num: str) -> int:
        return max(0, self.recur(num, 0, 0))
    
    
    def recur(self, num: str, i: int, last: int) -> int:
        if i == len(num):
            return 1
        if num[i] == '0':
            return -1
        
        options = 0
        
        for j in range(i+1, len(num)+1):
            nex = int(num[i: j])
            if nex >= last:
                option = self.recur(num, j, nex)
                if option != -1:
                    options += option
                    
        return options

print(Solution().numberOfCombinations("99999"))
