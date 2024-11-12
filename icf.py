import sys
import oracledb

print "Argument list len", len(sys.argv)
if len(sys.argv)>1:
   i=int(sys.argv[1])
else:
   i=3
   print "No argument, setting cycles equal to ", i

# connect to db
conn = oracledb.connect(user="appl1", password="DataBase__21c", dsn="10.0.1.185/pdb1.sub07041409111.testvcn.oraclevcn.com")
print("Database version:", conn.version)

for i in range(0, i):
    print "Cycle index: ",i+1
