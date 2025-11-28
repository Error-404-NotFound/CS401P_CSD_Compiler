sumNumbers: 
@t0 = 0 INT
- INT total
total = @t0 INT
@t1 = 0 INT
- INT i
i = @t1 INT
@t2 = 1 INT
- INT i
i = @t2 INT

#L0:
@t3 = 10 INT
@t4 = 2 INT
@t5 = i <= @t3 INT

if @t5 GOTO #L1 else GOTO #L2

#L3:
i = i + @t4 INT
GOTO #L0

#L1:
@t5 = total + i INT
total = @t5 INT
GOTO #L3

#L2:
return total 
end:

