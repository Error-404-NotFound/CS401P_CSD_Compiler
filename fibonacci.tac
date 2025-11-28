main: 
- INT n
input n INT
print "Fibonacci Series:" STRING_LITERAL
@t0 = 1 INT
- INT a
a = @t0 INT
@t1 = 1 INT
- INT b
b = @t1 INT
@t2 = 1 INT
@t3 = n == @t2 INT
if @t3 GOTO #L1 else GOTO #L2
#L1:
print a INT
return a 
GOTO #L0
#L2:
#L0:
print b INT
print a INT

#L3:
@t3 = 2 INT
@t4 = n - @t3 INT

if @t4 GOTO #L4 else GOTO #L5

#L4:
@t4 = a + b INT
- INT c
c = @t4 INT
b = a INT
a = c INT
print c INT
GOTO #L3

#L5:
@t4 = 0 INT
return @t4 
end:

