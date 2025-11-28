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
if @t3 GOTO #L1 else GOTO #L2
#L1:
@t4 = y INT
if @t4 GOTO #L4 else GOTO #L5
#L4:
@t5 = 12 INT
res = @t5 INT
GOTO
#L5:
#L6:
@t6 = 10 INT
res = @t6 INT
GOTO
#L3:
GOTO
#L2:
#L7:
@t7 = 99 INT
res = @t7 INT
GOTO
#L0:
return res
end: