# Built-in functions
# —-----------------

def abs(x):
    return -x if x < 0 else x

__builtins__['abs'] = abs

def all(iterable):
    for element in iterable:
        if not element:
            return False
    return True

__builtins__['all'] = all

def any(iterable):
    for element in iterable:
        if element:
            return True
    return False

__builtins__['any'] = any

# basestring() not supported
# bin(x)

#def bool(x=False):
#    return True if x else False

# bytearray
# callable
# chr
# classmethod

def cmp(x, y):
    if x == y: return 0
    if x < y: return -1
    if x > y: return +1

__builtins__['cmp'] = cmp

# compile

#def enumerate(sequence, start=0):
#    result = []
#    start = 0
#    for element in sequence:
#        result.append((start, element))
#        start += 1
#    return result

def filter(function, iterable):
    result = []
    for element in iterable:
        if function(element):
            result.append(element)
    return result

__builtins__['filter'] = filter

def map(function, iterable):
    result = []
    for element in iterable:
        result.append(function(element))
    return result

__builtins__['map'] = map

def max(iterable):
    x = None
    for element in iterable:
        if x is None or element > x:
            x = element
    return x

__builtins__['max'] = max

def min(iterable):
    x = None
    for element in iterable:
        if x is None or element < x:
            x = element
    return x

__builtins__['min'] = min

#def next(iterator, default=None):
#    try:
#        return iterator.next()
#    except StopIteration:
#        if default is not None:
#            return default
#        raise
#
#def range(start, stop=None, step=1):
#    if step == 0:
#        raise ValueError("step argument must not be zero")
#    if stop is None:
#        start, stop = 0, start
#    if stop < start:
#        if step > 0:
#            return []
#        start, stop = stop, start
#    else:
#        if step < 0:
#            return []
#    result = []
#    while start < stop:
#        result.append(start)
#        start += step
#    return result
#
#def reduce(function, iterable, initializer=None):
#    x = initializer
#    for element in iterable:
#        if x is None:
#            x = element
#        else:
#            x = function(x, element)
#    return x

def reversed(sequence):
    result = []
    length = len(sequence)
    while length > 0:
        length -= 1
        result.append(sequence[length])
    return result

__builtins__['reversed'] = reversed

def sum(iterable):
    x = None
    for element in iterable:
        if x is None:
            x = element
        else:
            x += element
    return x

__builtins__['sum'] = sum

def zip(iterable1, iterable2):
    result = []
    iter1 = iter(iterable1)
    iter2 = iter(iterable2)
    try:
        while True:
            result.append((iter1.next(), iter2.next()))
    except StopIteration:
        return result

__builtins__['zip'] = zip

print("builtins loaded.")
