arraySum:
- INT arr [ 5 ]
@t0 = 0 INT
- INT sum
sum = @t0 INT
@t1 = 0 INT
- INT index
index = @t1 INT
@t2 = 10 INT
arr [ 0 ] = @t2 INT
@t3 = 20 INT
arr [ 1 ] = @t3 INT
@t4 = 30 INT
arr [ 2 ] = @t4 INT
@t5 = 40 INT
arr [ 3 ] = @t5 INT
@t6 = 50 INT
arr [ 4 ] = @t6 INT

#L0:
@t7 = 5 INT
@t8 = index < @t7 INT

if @t8 GOTO #L1 else GOTO #L2

#L1:
@t9 = arr [ index ] INT
@t10 = sum + @t9 INT
sum = @t10 INT
@t11 = 1 INT
@t12 = index + @t11 INT
index = @t12 INT
GOTO #L0

#L2:
print sum INT
return sum
end: