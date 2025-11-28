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
@t2 = 2 INT
@t3 = count == @t2 INT
if @t3 GOTO #L4 else GOTO #L5
#L4:
print count INT
GOTO #L3
#L5:
#L3:
@t3 = 1 INT
@t4 = count + @t3 INT
count = @t4 INT
GOTO #L0

#L2:
return count 
end:

