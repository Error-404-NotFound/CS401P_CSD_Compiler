classifyChar:
- CHAR ch
- INT category
@t0 = 'a' CHAR
ch = @t0 CHAR
@t1 = 0 INT
category = @t1 INT
@t3 = ch == 'a' INT
if @t3 GOTO #L1 else GOTO #L2
#L1:
@t3 = 1 INT
category = @t3 INT
GOTO
#L2:
@t4 = ch == 'b' INT
if @t4 GOTO #L3 else GOTO #L4
#L3:
@t4 = 2 INT
category = @t4 INT
GOTO
#L4:
#L5:
@t6 = 99 INT
category = @t6 INT
GOTO
#L0:
return category
end: