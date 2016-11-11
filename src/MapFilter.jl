
module MapFilter

"""
[1,2,3] |> map(x->x+1)
"""
map(f::Function) = xs->Base.map(f,xs)
map(f1::Function,f2::Function) = map( x->f2(f1(x)) )
map(f1::Function,f2::Function,ff::Function...) = map(x->f2(f1(x)), ff...)



"""
    [1,2,3,4] |> filter(x->x<3) # [1,2]
    [1,2,3,4] |> filter(x->x>1, x->x<4) # [2,3] - logical 'and'
    
"""
filter(f::Function) = itr->Base.filter(f,itr)
filter(f1::Function, f2::Function) = itr->filter( x->f1(x)&&f2(x), itr )
filter(f1::Function, f2::Function, ff::Function...) = 
    filter(x->f1(x)&&f2(x), ff)


# ---------------------------- mapfilter -------------------
immutable EMapFil{F,I}
    f::F
    i::I
end


function Base.next(itr::EMapFil, s)
    (rv,si) = s
    si2=advance_itr(itr, si)
    (rv,si2)
end

function Base.start(itr::EMapFil)
    si = start(itr.i)
    advance_itr(itr, si)
end

function advance_itr(itr,si)
    while !done(itr.i,si)
    (v,si)=next(itr.i,si)
    rv=itr.f(v)
    if rv!=nothing
        return (rv,si)
    end
    end
    (nothing,)
end

Base.done(itr::EMapFil, s) = s[1]==nothing



"""
    mapfilter(func,iter)->iter
    mapfilter(func)->iter->iter
    
    mapfilter(func1,func2,other...)->mapfilter(comp(func2,func1),other...)
    Filter and map 2 in 1.
    Creates new collection iterator like map.
    But if func returns nothing, then current item of iter will be skipped.
"""
mapfilter(f::Function, itr) = EMapFil(f,itr)
mapfilter(f::Function) = itr->mapfilter(f,itr)
mapfilter(f1::Function,f2::Function,other...) = mapfilter( (x...)->f1(f2(x...)) , other...)
mapfilter(f::Function, itr::EMapFil) = mapfilter(f, itr.f, itr.i)




end # modulemodule MapFilter


