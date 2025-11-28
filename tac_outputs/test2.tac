arraySum: 
- INT arr [ 5 ] 
@t0 = 0 INT
- INT sum
sum = @t0 INT
@t1 = 0 INT
- INT index
index = @t1 INT
@t2 = 0 INT
@t3 = 10 INT
arr [ @t2 ] = @t3 INT
@t4 = 1 INT
@t5 = 20 INT
arr [ @t4 ] = @t5 INT
@t6 = 2 INT
@t7 = 30 INT
arr [ @t6 ] = @t7 INT
@t8 = 3 INT
@t9 = 40 INT
arr [ @t8 ] = @t9 INT
@t10 = 4 INT
@t11 = 50 INT
arr [ @t10 ] = @t11 INT

#L0:
@t12 = 5 INT
@t13 = index < @t12 INT

if @t13 GOTO #L1 else GOTO #L2

#L1:
@t13 = arr [ index ] INT
@t14 = sum + @t13 INT
sum = @t14 INT
@t13 = 1 INT
@t14 = index + @t13 INT
index = @t14 INT
GOTO #L0

#L2:
print sum INT
return sum 
end:

