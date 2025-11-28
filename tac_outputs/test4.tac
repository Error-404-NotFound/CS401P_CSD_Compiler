class Person
- field INT name
- field INT age
Person::greet:
print "Hello" STRING_LITERAL
@t0 = 0 INT
return @t0 
end Person::greet
endclass Person
record Point
- field INT x
- field INT y
endrecord Point
main: 
- Person p
p = make Person
@t1 = 12 INT
p.name = @t1 INT
@t2 = 30 INT
p.age = @t2 INT
@t3 = @call p.greet 
- Point pt
pt = make Point
@t4 = 10 INT
pt.x = @t4 INT
@t5 = 20 INT
pt.y = @t5 INT
discard p Person
@t6 = 0 INT
return @t6 
end:

