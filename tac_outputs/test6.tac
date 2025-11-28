countdown: 
@t0 = 5 INT
- INT count
count = @t0 INT
@t1 = 0 INT
- INT done
done = @t1 INT

#L0:
@t2 = 1 INT
@t3 = done == @t2 INT

if @t3 GOTO #L1 else GOTO #L2

#L1:
print count INT
@t3 = 1 INT
@t4 = count - @t3 INT
count = @t4 INT
@t4 = 0 INT
@t5 = count <= @t4 INT
if @t5 GOTO #L4 else GOTO #L5
#L4:
@t5 = 1 INT
done = @t5 INT
GOTO #L3
#L5:
print "continuing" STRING_LITERAL
#L3:
GOTO #L0

#L2:
@t6 = 0 INT
return @t6 
end:

