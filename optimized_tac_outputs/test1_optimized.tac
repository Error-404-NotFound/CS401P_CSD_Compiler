testWhileLoop:
@t0 = 0 INT
- INT count
count = @t0 INT
@t1 = 5 INT
- INT limit
limit = @t1 INT

#L0:
@t2 = count < limit INT
if @t2 GOTO #L1 else GOTO #L2

#L1:
@t3 = count == 2 INT
if @t3 GOTO #L4 else GOTO #L5
#L4:
print count INT
GOTO #L3
#L5:
#L3:
@t4 = count + 1 INT
count = @t4 INT
GOTO #L0

#L2:
return count
end: