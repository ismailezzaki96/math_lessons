import os
import sys

sys.stdout = open(os.devnull, 'w')

sys.stdout = sys.__stdout__
import sys

print(sys.version)

