main: 
@t0 = 15 INT
- INT n
n = @t0 INT
print "Fibonacci Series:" STRING_LITERAL
@t1 = 1 INT
- INT a
a = @t1 INT
@t2 = 1 INT
- INT b
b = @t2 INT
@t3 = 1 INT
@t4 = n == @t3 INT
if @t4 GOTO #L1 else GOTO #L2
#L1:
print a INT
return a 
GOTO #L0
#L2:
#L0:
print b INT
print a INT

#L3:
@t4 = 2 INT
@t5 = n - @t4 INT

if @t5 GOTO #L4 else GOTO #L5

#L4:
@t5 = a + b INT
- INT c
c = @t5 INT
b = a INT
a = c INT
print c INT
GOTO #L3

#L5:
@t5 = 0 INT
return @t5 
end:

