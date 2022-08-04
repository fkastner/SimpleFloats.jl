module SimpleFloats

using StaticArrays
import Base: bitstring
import Base.Math: significand, exponent
import Base: one, zero, AbstractFloat

export SimpleFloat

# B: base
# L: length of mantissa
# M: length of exponent
struct SimpleFloat{B,L,M} <: Number
    mantissa_negative::Bool
    exponent_negative::Bool
    mantissa::SVector{L,Int64}
    exponent::SVector{M,Int64}

    function SimpleFloat{B,L,M}(sign_mantissa, mantissa_digits, sign_exponent, exponent_digits) where {B,L,M}
        if !(all(0 .<= mantissa_digits .< B) && all(0 .<= exponent_digits .< B))
            error("Digits have to be in the set {0,1,...,$(B-1)}")
        end
        return new(sign_mantissa == -1, sign_exponent == -1, mantissa_digits, exponent_digits)
    end
end

SimpleFloat(base, sign_mantissa, mantissa, sign_exponent, exponent) = SimpleFloat{base,length(mantissa),length(exponent)}(sign_mantissa, mantissa, sign_exponent, exponent)
function SimpleFloat{B,L,M}(n::Integer) where {B,L,M}
    mantissa = reverse!(digits(n, base=B))
    len_m = length(mantissa)
    len_m <= L || throw(InexactError(Symbol(SimpleFloat{B,L,M}), SimpleFloat{B,L,M}, n))
    len_m < L && (mantissa = vcat(mantissa, zeros(L - len_m)))
    exponent = reverse!(digits(len_m - 1, base=B))
    len_e = length(exponent)
    len_e <= M || throw(InexactError(Symbol(SimpleFloat{B,L,M}), SimpleFloat{B,L,M}, n))
    len_e < M && (exponent = vcat(zeros(M - len_e), exponent))
    SimpleFloat{B,L,M}(sign(n), mantissa, +1, exponent)
end

## Properties of SimpleFloat's
# bitstring(s::SimpleFloat) = "3"
# significand(s::SimpleFloat) = 3
# exponent(s::SimpleFloat) = 3

## Pretty printing
function Base.show(io::IO, s::SimpleFloat)
    print(io,
        s.mantissa_negative ? "-" : "+",
        s.mantissa[1],
        ".",
        s.mantissa[2:end]...,
        "E",
        s.exponent_negative ? "-" : "+",
        s.exponent...
    )
end
Base.show(io::IO, ::MIME"text/plain", n::SimpleFloat{B}) where {B} = print(io, "Simple float (base $B):\n   ", n)

## Promotion & Conversion
one(::Type{SimpleFloat{B,L,M}}) where {B,L,M} = SimpleFloat{B,L,M}(1, ntuple(i -> i == 1, L), 1, ntuple(i -> 0, M))
zero(::Type{SimpleFloat{B,L,M}}) where {B,L,M} = SimpleFloat{B,L,M}(1, ntuple(i -> 0, L), 1, ntuple(i -> 0, M))

AbstractFloat(s::SimpleFloat{B,L,M}) where {B,L,M} = sum(s.mantissa[i] * B^(-i + 1.0) for i = 1:L) * B^(sum(s.exponent[i] * B^(M - i) for i = 1:M))

end # module
