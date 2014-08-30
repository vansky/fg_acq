
#python ttest.py file1 file2
from __future__ import division
import scipy.stats
import numpy
import sys
import ast

comparevector = {'Tot':[[],[]],'That':[[],[]],'S':[[],[]],'O':[[],[]],'Wh':[[],[]]}
#comparevector = {'Tot':[[],[]]}

from math  import sqrt
from scipy import stats
 
def mcnemar(A,B, C,D, alpha= 0.05, onetailed = False,verbose= False):
    """
    Performs a mcnemar test.
       A,B,C,D- counts in the form
        A    B  A+B
        C    D  C+D
       A+C  B+D  n
 
       alpha - level of significance
       onetailed -False for two-tailed test
                  True for one-tailed test 
    Returns True if Null hypotheses pi1 == pi2 is accepted
    else False.
    """
    tot = float(A + B + C + D)
    Z = (B-C)/ sqrt(B+C)
 
    if verbose:
        print "McNemar Test with A,B,C,D = ", A,B, C,D
        print "Ratios:p1, p2 = ",(A+B)/tot, (C + D) /tot
        print "Z test statistic Z = ", Z
 
 
    if onetailed:
       if (B-C> 0):
         zcrit2 = stats.norm.ppf(1-alpha)
         result = True if (Z < zcrit2)else False
         if verbose:
            print "Upper critical value=", zcrit2
            print "Decision:",  "Accept " if (result) else "Reject ",
            print "Null hypothesis at alpha = ", alpha
       else:
         zcrit1 = stats.norm.ppf(alpha)
         result = False if (Z < zcrit1) else False
         if verbose:
            print "Lower critical value=", zcrit1
            print "Decision:",  "Accept " if (result) else "Reject ",
            print "Null hypothesis at alpha = ", alpha
 
 
    else:
       zcrit1 = stats.norm.ppf(alpha/2.0)
       zcrit2 = stats.norm.ppf(1-alpha/2.0)
 
       result = True if (zcrit1 < Z < zcrit2) else False
       if verbose:
          print "Lower and upper critical limits:", zcrit1, zcrit2
          print "Decision:","Accept " if result else "Reject ",
          print "Null hypothesis at alpha = ", alpha
 
    return result


with open(sys.argv[1],'r') as file1:
  atts = []
  for line in file1.readlines():
    if line[0:2] == 'at':
      atts = ast.literal_eval(line.split(':')[1].strip())
    elif line[0:2] == 'a:':
      #test output
#      sys.stdout.write(str(line[2:].strip().split())+'\n')
      try:
        P = int(line[2:].strip().split()[0][2]) / int(line[2:].strip().split()[0][4])
      except:
        P = 0
      try:
        R = int(line[2:].strip().split()[1][2]) / int(line[2:].strip().split()[1][4])
      except:
        R = 0

      if P+R == 0:
        F = 0
      else:
        F = 2*P*R / (P+R)
      comparevector['Tot'][0].append(F)
      if 'W' in atts:
        comparevector['Wh'][0].append(F)
      if 'T' in atts:
        comparevector['That'][0].append(F)
      if 'S' in atts:
        comparevector['S'][0].append(F)
      if 'O' in atts:
        comparevector['O'][0].append(F)


with open(sys.argv[2],'r') as file2:
  for line in file2.readlines():
    if line[0:2] == 'at':
      atts = ast.literal_eval(line.split(':')[1].strip())
    elif line[0:2] == 'a:':
      #test output
      try:
        P = int(line[2:].strip().split()[0][2]) / int(line[2:].strip().split()[0][4])
      except:
        P = 0
      try:
        R = int(line[2:].strip().split()[1][2]) / int(line[2:].strip().split()[1][4])
      except:
        R = 0

      if P+R == 0:
        F = 0
      else:
        F = 2*P*R / (P+R)
      comparevector['Tot'][1].append(F)
      if 'W' in atts:
        comparevector['Wh'][1].append(F)
      if 'T' in atts:
        comparevector['That'][1].append(F)
      if 'S' in atts:
        comparevector['S'][1].append(F)
      if 'O' in atts:
        comparevector['O'][1].append(F)

#for si in range(len(comparevector[0])):
#  for wi in range(len(comparevector[0][i])):
#    if type(comparevector[0][si][wi][0]) == type(()):

#What are A,B,C,D?
#print mcnemar(A, B, C, D,alpha = 0.05, verbose=True)

for key in comparevector.keys():
  sys.stdout.write(key+': '+str(stats.ttest_rel(comparevector[key][0],comparevector[key][1]))+'\n')
