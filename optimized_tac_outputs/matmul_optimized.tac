main:
- INT a [ 9 ]
a [ 0 ] = 1 INT
a [ 1 ] = 2 INT
a [ 2 ] = 3 INT
a [ 3 ] = 4 INT
a [ 4 ] = 5 INT
a [ 5 ] = 6 INT
a [ 6 ] = 7 INT
a [ 7 ] = 8 INT
a [ 8 ] = 9 INT
- INT b [ 9 ]
b [ 0 ] = 9 INT
b [ 1 ] = 8 INT
b [ 2 ] = 7 INT
b [ 3 ] = 6 INT
b [ 4 ] = 5 INT
b [ 5 ] = 4 INT
b [ 6 ] = 3 INT
b [ 7 ] = 2 INT
b [ 8 ] = 1 INT
@t0 = 0 INT
- INT i
i = @t0 INT
print "The contents of matrix 1:\n" STRING_LITERAL

#L0:
@t1 = 9 INT
@t2 = i < @t1 INT

if @t2 GOTO #L1 else GOTO #L2

#L1:
@t2 = a [ i ] INT
print @t2 INT
print " " STRING_LITERAL
@t3 = 1 INT
@t4 = i + @t3 INT
i = @t4 INT
GOTO #L0

#L2:
print "\n" STRING_LITERAL
print "The contents of matrix 2:\n" STRING_LITERAL
@t4 = 0 INT
i = @t4 INT

#L3:
@t5 = 9 INT
@t6 = i < @t5 INT

if @t6 GOTO #L4 else GOTO #L5

#L4:
@t6 = b [ i ] INT
print @t6 INT
print " " STRING_LITERAL
@t7 = 1 INT
@t8 = i + @t7 INT
i = @t8 INT
GOTO #L3

#L5:
- INT c [ 9 ]
@t8 = 0 INT
- INT row
row = @t8 INT

#L6:
@t9 = 3 INT
@t10 = row < @t9 INT

if @t10 GOTO #L7 else GOTO #L8

#L7:
@t10 = 0 INT
- INT col
col = @t10 INT

#L9:
@t11 = 3 INT
@t12 = col < @t11 INT

if @t12 GOTO #L10 else GOTO #L11

#L10:
@t12 = 0 INT
- INT sum
sum = @t12 INT
@t13 = 0 INT
- INT k
k = @t13 INT

#L12:
@t14 = 3 INT
@t15 = k < @t14 INT

if @t15 GOTO #L13 else GOTO #L14

#L13:
@t15 = 3 INT
@t16 = 0 INT
@t17 = 0 INT
@t19 = 1 INT
#L16:
@t18 = @t17 < @t15  INT
if @t18 GOTO #L17 else GOTO #L18
#L17:
@t16 = @t16 + row  INT
@t17 = @t17 + @t19  INT
GOTO #L16
#L18:
@t17 = @t16 + k INT
@t18 = a [ @t17 ] INT
@t19 = 3 INT
@t16 = 0 INT
@t17 = 0 INT
@t21 = 1 INT
#L20:
@t20 = @t17 < @t19  INT
if @t20 GOTO #L21 else GOTO #L22
#L21:
@t16 = @t16 + k  INT
@t17 = @t17 + @t21  INT
GOTO #L20
#L22:
@t17 = @t16 + col INT
@t20 = b [ @t17 ] INT
@t21 = 0 INT
@t16 = 0 INT
@t22 = 1 INT
#L24:
@t17 = @t16 < @t20  INT
if @t17 GOTO #L25 else GOTO #L26
#L25:
@t21 = @t21 + @t18  INT
@t16 = @t16 + @t22  INT
GOTO #L24
#L26:
@t16 = sum + @t21 INT
sum = @t16 INT
@t17 = 1 INT
@t22 = k + @t17 INT
k = @t22 INT
GOTO #L12

#L14:
@t18 = 3 INT
@t20 = 0 INT
@t21 = 0 INT
@t22 = 1 INT
#L28:
@t16 = @t21 < @t18  INT
if @t16 GOTO #L29 else GOTO #L30
#L29:
@t20 = @t20 + row  INT
@t21 = @t21 + @t22  INT
GOTO #L28
#L30:
@t21 = @t20 + col INT
c [ @t21 ] = sum INT
@t16 = 1 INT
@t22 = col + @t16 INT
col = @t22 INT
GOTO #L9

#L11:
@t20 = 1 INT
@t22 = row + @t20 INT
row = @t22 INT
GOTO #L6

#L8:
print "\n" STRING_LITERAL
@t22 = 0 INT
i = @t22 INT

#L31:
@t23 = 9 INT
@t24 = i < @t23 INT

if @t24 GOTO #L32 else GOTO #L33

#L32:
@t24 = c [ i ] INT
print @t24 INT
@t25 = 1 INT
@t26 = i + @t25 INT
@t27 = 3 INT
@t28 = 0 INT
@t29 = @t26 INT
@t31 = 1 INT
#L36:
@t30 = @t29 >= @t27  INT
if @t30 GOTO #L37 else GOTO #L38
#L37:
@t29 = @t29 - @t27  INT
GOTO #L36
#L38:
@t28 = @t29  INT
@t29 = 0 INT
@t30 = @t28 == @t29 INT
if @t30 GOTO #L39 else GOTO #L40
#L39:
print "\n" STRING_LITERAL
GOTO #L34
#L40:
print " " STRING_LITERAL
#L34:
@t31 = 1 INT
@t26 = i + @t31 INT
i = @t26 INT
GOTO #L31

#L33:
@t28 = 0 INT
return @t28
end: