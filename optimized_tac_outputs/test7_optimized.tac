testMatch:
- INT x
@t0 = 2 INT
x = @t0 INT
@t1 = 0 INT
- INT a
a = @t1 INT
@t2 = x INT
@t3 =  == 1
if @t3 GOTO #L1 else GOTO #L2
#L1:
@t3 = 10 INT
a = @t3 INT
GOTO
#L2:
@t4 =  == 2
if @t4 GOTO #L3 else GOTO #L4
#L3:
@t4 = 20 INT
a = @t4 INT
GOTO
#L4:
@t5 =  == 3
if @t5 GOTO #L5 else GOTO #L6
#L5:
@t5 = 30 INT
a = @t5 INT
GOTO
#L6:
@t7 = 99 INT
a = @t7 INT
GOTO
#L0:
return a
end: