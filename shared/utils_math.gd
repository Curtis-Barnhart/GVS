extends Object

const ClassLoader = preload("res://gvs_class_loader.gd")
const MathUtils = ClassLoader.shared.Math


## Performs interpolation on a logistic curve
## between a and b.
## A t value of 0 
static func half_log_interp(a: float, b: float, t: float) -> float:
    return MathUtils.log_interp(2*a - b, b, (t + 1)/2)


## Performs interpolation on a logistic curve
## between a and b.
## A t value of 0 is equivalent sigma((t + 6)/12) * (b - a) + a 
static func log_interp(a: float, b: float, t: float) -> float:
    return MathUtils.unary_log_interp(t) \
            * (b - a) \
            + a


## Performs interpolation on a logistic curve
## between a and b.
## A t value of 0 is equivalent sigma((t + 6)/12) * (b - a) + a
## @deprecated
static func log_interp_v(a: Vector2, b: Vector2, t: float) -> Vector2:
    return a.lerp(b, MathUtils.unary_log_interp(t))


## Maps from [0, 1] to [0, 1] using a logistic curve.
## That is, inputs near 0 return values very near to 0,
## and inputs near 1 return values very close to 1.[br][br]
##
## [param t]: linear input value.[br]
## [param return]: logistic output value.
static func unary_log_interp(t: float) -> float:
    return (1/(1 + exp((-16*t) + 8)))
