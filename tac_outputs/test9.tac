nestedMatch: 
- INT x
- INT y
- INT res
@t0 = 1 INT
x = @t0 INT
@t1 = 2 INT
y = @t1 INT
@t2 = 0 INT
res = @t2 INT
@t3 = x INT
@t4 =  == 1 
if @t4 GOTO #L1 else GOTO #L2
#L1:
@t4 = y INT
@t5 =  == 2 
if @t5 GOTO #L4 else GOTO #L5
#L4:
@t5 = 12 INT
res = @t5 INT
GOTO 
#L5:
#L6:
@t7 = 10 INT
res = @t7 INT
GOTO 
#L3:
GOTO 
#L2:
#L7:
@t8 = 99 INT
res = @t8 INT
GOTO 
#L0:
return res 
end:

