class_name utils_math
extends Object


## Performs interpolation on a logistic curve
## between a and b.
## A t value of 0 
static func half_log_interp(a: float, b: float, t: float) -> float:
    return utils_math.log_interp(2*a - b, b, (t + 1)/2)


## Performs interpolation on a logistic curve
## between a and b.
## A t value of 0 is equivalent sigma((t + 6)/12) * (b - a) + a 
static func log_interp(a: float, b: float, t: float) -> float:
    return (1/(1 + exp((-16*t) + 8))) \
            * (b - a) \
            + a


## Performs interpolation on a logistic curve
## between a and b.
## A t value of 0 is equivalent sigma((t + 6)/12) * (b - a) + a 
static func log_interp_v(a: Vector2, b: Vector2, t: float) -> Vector2:
    return (1/(1 + exp((-16*t) + 8))) \
            * (b - a) \
            + a
