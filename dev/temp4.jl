macro change_operation(ex)
  # Change the operation to mutiplication
  ex.args[1] = :*
  # Return an expression to print the result
  return :(println($(ex)))
end

ex = macroexpand(:(@change_operation 1 + 2 ))


T = [[0.272545164 6.5637631e-37 7.93970182e-6 8.61092244e-5 0.165656847 0.287081146 0.000218659173 4.06806091e-13 0.274399041 5.09466694e-6]
 [0.0835696383 7.05396766e-6 0.206100213 1.52600546e-11 1.53908757e-8 6.5269808e-11 0.673013596 0.0193819808 0.0179275025 3.2272789e-18]
 [0.886728867 8.63212428e-7 3.94046562e-11 0.110467781 1.11735715e-6 2.12946427e-18 5.16880247e-8 0.000236340361 0.00111600188 0.00144897701]
 [8.16557898e-11 0.0168992485 6.27227283e-14 0.010767298 0.426756301 1.78050405e-9 6.41316248e-5 0.321159984 0.0369047216 0.187448314]
 [0.130652141 4.70465408e-6 0.000473601393 0.0378509164 9.06618543e-10 0.000778622816 0.00029383779 0.829914494 8.69688804e-26 3.16817317e-5]
 [0.223054659 0.288152163 7.35806925e-19 0.0185562602 1.73073908e-8 0.400936069 1.17437994e-12 0.0443974641 0.0249033671 7.2202285e-18]
 [4.78064507e-16 0.320444079 0.00385904296 1.26156421e-9 0.00688364264 0.00447186979 0.156660567 0.169796226 0.333780163 0.00410440864]
 [4.84470444e-13 2.5025163e-14 2.78748146e-7 0.00245132866 3.03033036e-12 0.00284425237 8.49830551e-7 6.60111797e-8 0.994702713 5.11768273e-7]
 [0.16839645 1.80280379e-7 5.68958062e-11 0.134838199 0.00020810431 0.0861188042 0.0517409105 0.361825373 3.31239961e-11 0.196871978]
 [0.0474764005 1.16126593e-6 5.96036112e-8 0.00128470373 1.30134792e-6 0.0374283978 0.310068428 2.27075277e-19 0.00647484474 0.597264703]];
using Turing, Distributions
K = 10
N = 51
initial = fill(1.0 / K, K)
means = collect(1.0:K)*5

@model hmmdemo begin
    states = tzeros(Int,N)
    # T = TArray{Array{Float64,}}

    @assume states[1] ~ Categorical(initial)
    for i = 2:N
        @assume states[i] ~ Categorical(vec(T[states[i-1],:]))
        @assume obs[i] ~ Normal(means[states[i]], 0.1)
    end
    @predict obs
end

srand(1234)
chain = sample(hmmdemo, PG(10,10));

# MethodError: `convert` has no method matching convert(::Type{ForwardDiff.Dual{N,T<:Real}}, ::Array{Float64,1})
# This may have arisen from a call to the constructor ForwardDiff.Dual{N,T<:Real}(...),
# since type constructors fall back to convert methods.
# Closest candidates are:
#   ForwardDiff.Dual{N,T}(::T, !Matched::ForwardDiff.Partials{N,T})
#   ForwardDiff.Dual{N,A,B}(::A, !Matched::ForwardDiff.Partials{N,B})
#   call{T}(::Type{T}, ::Any)
#   ...
#  in schedule_and_wait at task.jl:343
#  in consume at task.jl:259
#  in consume at /Users/kai/.julia/v0.4/Turing/src/core/container.jl:85
#  in run at /Users/kai/.julia/v0.4/Turing/src/samplers/pgibbs.jl:30
#  in sample at /Users/kai/.julia/v0.4/Turing/src/core/intrinsic.jl:20
#  in include_string at /Users/kai/.julia/v0.4/CodeTools/src/eval.jl:28
#  in include_string at /Users/kai/.julia/v0.4/CodeTools/src/eval.jl:32
#  [inlined code] from /Users/kai/.julia/v0.4/Atom/src/eval.jl:39
#  in anonymous at /Users/kai/.julia/v0.4/Atom/src/eval.jl:62
#  in withpath at /Users/kai/.julia/v0.4/Requires/src/require.jl:37
#  in withpath at /Users/kai/.julia/v0.4/Atom/src/eval.jl:53
#  [inlined code] from /Users/kai/.julia/v0.4/Atom/src/eval.jl:61
#  in anonymous at task.jl:58

obs = chain.value[1].value[:obs]
srand()
